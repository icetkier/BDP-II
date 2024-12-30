#-----------------------------------
# Julia Machalica
# Nr indeksu: 406342
# Changelog:
#       - 30.12.2024 --- Wersja 1.0
#-----------------------------------

# Parametry
INDEX=406342
URL="http://home.agh.edu.pl/~wsarlej/dyd/bdp2/materialy/cw10/InternetSales_new.zip"
PASSWORD="bdp2agh"
TIMESTAMP=$(date +"%m%d%Y")
ZIP_NAME="InternetSales_new.zip"
INPUT_FILE="InternetSales_new.txt"
SUBFOLDER="PROCESSED"
GOOD_OUTPUT_FILE="${SUBFOLDER}/${TIMESTAMP}_InternetSales_new.csv"
BAD_OUTPUT_FILE="${SUBFOLDER}/InternetSales_new.bad_${TIMESTAMP}.csv"
EXPORT_FILE="${SUBFOLDER}/CUSTOMERS_${INDEX}.csv"
LOG_FILE="${SUBFOLDER}/process_data_${TIMESTAMP}.log"
MYSQL_USER="jumachal"               
MYSQL_PASSWORD_BASE64="MmZ5aXM1aWNvVjZwNjFrYg==" 
MYSQL_PASSWORD=$(echo "$MYSQL_PASSWORD_BASE64" | base64 --decode) 
MYSQL_HOST="mysql.agh.edu.pl"        
MYSQL_PORT="3306"         
MYSQL_DATABASE="jumachal"
#echo ${LOG_FILE}


# Pobranie pliku .zip z internetu
echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Preparing the file"
if [ -f ${ZIP_NAME} ]; then
        rm ${ZIP_NAME}
fi
wget -q --no-use-server-timestamps -O ${ZIP_NAME} $URL
if [[ $? -ne 0 ]]; then
  echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Downloading file - Failed" > $LOG_FILE
  exit 1
else
  echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Downloading file - Successful" > $LOG_FILE
fi

# Rozpakowanie pliku .zip
unzip -q -P ${PASSWORD} -o ${ZIP_NAME}
find . -type f -exec touch {} +
if [[ $? -ne 0 ]]; then
  echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Unzipping file - Failed" >> $LOG_FILE
  exit 1
else
  echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Unzipping file - Successful" >> $LOG_FILE
fi

# Stworzenie folderu na pliki wyjściowe
mkdir -p ${SUBFOLDER}
# Wyodrębnienie nagłówka z pliku wejściowego
HEADER=$(head -n 1 "${INPUT_FILE}")
TMP_INPUT_FILE=$(mktemp)
tail -n +2 "${INPUT_FILE}" > "${TMP_INPUT_FILE}"
# Stworzenie plików tymczasowych
TMP_GOOD_FILE=$(mktemp)
TMP_BAD_FILE=$(mktemp)

# Usunięcie pustych linii
echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Validating the file"
awk 'NF > 0 {print}' "${TMP_INPUT_FILE}" > "${TMP_GOOD_FILE}"
if [[ $? -ne 0 ]]; then
  echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Removing blank lines - Failed" | tee -a $LOG_FILE
  exit 1
else
  echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Removing blank lines - Successful" >> $LOG_FILE
fi
# Liczenie
LINES_IN_GOOD=$(wc -l < "${TMP_GOOD_FILE}")
LINES_IN_BAD=$(wc -l < "${TMP_BAD_FILE}")
#echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - ${LINES_IN_GOOD}:${LINES_IN_BAD}" >> $LOG_FILE


# Usunięcie wartości SecretCode
cat "${TMP_GOOD_FILE}" > "${TMP_INPUT_FILE}"
> "${TMP_GOOD_FILE}"
CLEANED_FILE=$(mktemp)
awk -F'|' -v OFS='|' '{ $7 = ""; print }' "${TMP_INPUT_FILE}" > "${CLEANED_FILE}"
if [[ $? -ne 0 ]]; then
  echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Removing SecretCode - Failed" | tee -a $LOG_FILE
  exit 1
else
  echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Removing SecretCode - Successful" >> $LOG_FILE
fi
cat "${CLEANED_FILE}" > "${TMP_GOOD_FILE}"

# Odrzucenie duplikatów
cat "${TMP_GOOD_FILE}" > "${TMP_INPUT_FILE}"
> "${TMP_GOOD_FILE}"
SORTED_FILE=$(mktemp)
sort "${TMP_INPUT_FILE}" > "${SORTED_FILE}" 
awk -v good_file="${TMP_GOOD_FILE}" -v bad_file="${TMP_BAD_FILE}" '
{
    if ($0 in seen) {
        print $0 >> bad_file
    } else {
        print $0 >> good_file
        seen[$0] = 1
    }
}' "${SORTED_FILE}"
if [[ $? -ne 0 ]]; then
  echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Removing duplicates - Failed" | tee -a $LOG_FILE
  exit 1
else
  echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Removing duplicates - Successful" >> $LOG_FILE
fi
# Liczenie
LINES_IN_INPUT=$(wc -l < "${TMP_INPUT_FILE}")
LINES_IN_GOOD=$(wc -l < "${TMP_GOOD_FILE}")
LINES_IN_BAD=$(wc -l < "${TMP_BAD_FILE}")
#echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - ${LINES_IN_GOOD}:${LINES_IN_BAD}" >> $LOG_FILE
if [[ $((LINES_IN_GOOD + LINES_IN_BAD)) -ne $LINES_IN_INPUT ]]; then
  echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - ERROR: Line count mismatch. Input: ${LINES_IN_INPUT}, Good+Bad: $((LINES_IN_GOOD + LINES_IN_BAD))" | tee -a $LOG_FILE
  exit 2
fi

# Odrzucenie linii z nieprawidłową liczbą kolumn
cat "${TMP_GOOD_FILE}" > "${TMP_INPUT_FILE}"
> "${TMP_GOOD_FILE}"
NUM_COLUMNS=$(echo "${HEADER}" | awk -F'|' '{print NF}')
awk -v num_columns="${NUM_COLUMNS}" -F'|' '
NF == num_columns { print >> good_file }
NF != num_columns { print >> bad_file }
' good_file="${TMP_GOOD_FILE}" bad_file="${TMP_BAD_FILE}" "${TMP_INPUT_FILE}"
if [[ $? -ne 0 ]]; then
  echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Removing lines with wrong number of columns - Failed" | tee -a $LOG_FILE
  exit 1
else
  echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Removing lines with wrong number of columns - Successful" >> $LOG_FILE
fi
# Liczenie wierszy
LINES_IN_GOOD=$(wc -l < "${TMP_GOOD_FILE}")
LINES_IN_BAD=$(wc -l < "${TMP_BAD_FILE}")
#echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - ${LINES_IN_GOOD}:${LINES_IN_BAD}" >> $LOG_FILE
if [[ $((LINES_IN_GOOD + LINES_IN_BAD)) -ne $LINES_IN_INPUT ]]; then
  echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - ERROR: Line count mismatch. Input: ${LINES_IN_INPUT}, Good+Bad: $((LINES_IN_GOOD + LINES_IN_BAD))" | tee -a $LOG_FILE
  exit 2
fi

# Odrzucenie linii bez żadnych danych
cat "${TMP_GOOD_FILE}" > "${TMP_INPUT_FILE}"
> "${TMP_GOOD_FILE}"
awk -F'|' '
{
  incomplete = 0
  for (i = 1; i <= 6; i++) {
    if ($i == "" || $i == " " || $i == "	") {
      incomplete = 1
      break
    }
  }
  if (!incomplete) print >> good_file
  else print >> bad_file
}
' good_file="${TMP_GOOD_FILE}" bad_file="${TMP_BAD_FILE}" "${TMP_INPUT_FILE}"
if [[ $? -ne 0 ]]; then
  echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Removing lines with missing data - Failed" | tee -a $LOG_FILE
  exit 1
else
  echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Removing lines with missing data - Successful" >> $LOG_FILE
fi
LINES_IN_GOOD=$(wc -l < "${TMP_GOOD_FILE}")
LINES_IN_BAD=$(wc -l < "${TMP_BAD_FILE}")
#echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - ${LINES_IN_GOOD}:${LINES_IN_BAD}" >> $LOG_FILE
if [[ $((LINES_IN_GOOD + LINES_IN_BAD)) -ne $LINES_IN_INPUT ]]; then
  echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - ERROR: Line count mismatch. Input: ${LINES_IN_INPUT}, Good+Bad: $((LINES_IN_GOOD + LINES_IN_BAD))" | tee -a $LOG_FILE
  exit 2
fi

# Odrzucenie rekordów, dla których OrderQuantity > 100
cat "${TMP_GOOD_FILE}" > "${TMP_INPUT_FILE}"
> "${TMP_GOOD_FILE}"
awk -F'|' '{ 
    if ($5 <= 100) 
        print $0 >> "'${TMP_GOOD_FILE}'" 
    else 
        print $0 >> "'${TMP_BAD_FILE}'" 
}' "${TMP_INPUT_FILE}"
if [[ $? -ne 0 ]]; then
  echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Removing lines with OrderQuantity>100 - Failed" | tee -a $LOG_FILE
  exit 1
else
  echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Removing lines with OrderQuantity>100 - Successful" >> $LOG_FILE
fi
LINES_IN_GOOD=$(wc -l < "${TMP_GOOD_FILE}")
LINES_IN_BAD=$(wc -l < "${TMP_BAD_FILE}")
#echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - ${LINES_IN_GOOD}:${LINES_IN_BAD}" >> $LOG_FILE
if [[ $((LINES_IN_GOOD + LINES_IN_BAD)) -ne $LINES_IN_INPUT ]]; then
  echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - ERROR: Line count mismatch. Input: ${LINES_IN_INPUT}, Good+Bad: $((LINES_IN_GOOD + LINES_IN_BAD))" | tee -a $LOG_FILE
  exit 2
fi

# Odrzucenie rekordów ze złym formatem imienia i nazwiska
cat "${TMP_GOOD_FILE}" > "${TMP_INPUT_FILE}"
> "${TMP_GOOD_FILE}"
awk -F'|' -v OFS='|' '{
    if (substr($3, 1, 1) == "\"" && substr($3, length($3), 1) == "\"" && index($3, ",") > 0) {
        print $0 > "'${TMP_GOOD_FILE}'";
    } else {
        print $0 >> "'${TMP_BAD_FILE}'";
    }
}' "${TMP_INPUT_FILE}"
if [[ $? -ne 0 ]]; then
  echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Removing lines with wrong name format - Failed" >> $LOG_FILE
  exit 1
else
  echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Removing lines with wrong name format - Successful" >> $LOG_FILE
fi
LINES_IN_GOOD=$(wc -l < "${TMP_GOOD_FILE}")
LINES_IN_BAD=$(wc -l < "${TMP_BAD_FILE}")
#echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - ${LINES_IN_GOOD}:${LINES_IN_BAD}" >> $LOG_FILE
if [[ $((LINES_IN_GOOD + LINES_IN_BAD)) -ne $LINES_IN_INPUT ]]; then
  echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - ERROR: Line count mismatch. Input: ${LINES_IN_INPUT}, Good+Bad: $((LINES_IN_GOOD + LINES_IN_BAD))" | tee -a $LOG_FILE
  exit 2
fi

# Zmiana kolumny Customer_Name na FIRST_NAME i LAST_NAME
cat "${TMP_GOOD_FILE}" > "${TMP_INPUT_FILE}"
> "${TMP_GOOD_FILE}"
NEW_HEADER=$(head -n 1 "${INPUT_FILE}" | sed 's/Customer_Name/FIRST_NAME|LAST_NAME/')
awk -F'|' -v OFS='|' ' {
    name_without_quotes = substr($3, 2, length($3) - 2);
    split(name_without_quotes, name_parts, ",");
    first_name = (name_parts[2] ? name_parts[2] : "");  
    last_name = (name_parts[1] ? name_parts[1] : "");  
    print $1, $2, first_name, last_name, $4, $5, $6, $7;
}' "${TMP_INPUT_FILE}" >> "${TMP_GOOD_FILE}"
if [[ $? -ne 0 ]]; then
  echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Splitting Customer_Name column - Failed" | tee -a $LOG_FILE
  exit 1
else
  echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Splitting Customer_Name column - Successful" >> $LOG_FILE
fi

# Konwersja separatora dziesiętnego w kolumnie UnitPrice
cat "${TMP_GOOD_FILE}" > "${TMP_INPUT_FILE}"
> "${TMP_GOOD_FILE}"
awk -F'|' -v OFS='|' '{
    $7 = (index($7, ",") > 0 ? $7 : $7)
    gsub(",", ".", $7)
    print
}' "${TMP_INPUT_FILE}" > "${TMP_GOOD_FILE}"
if [[ $? -ne 0 ]]; then
  echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Converting decimal separator in UnitPrice column - Failed" | tee -a $LOG_FILE
  exit 1
else
  echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Converting decimal separator in UnitPrice column - Successful" >> $LOG_FILE
fi

# Zapisanie przefiltrowanych rekordów do plików wyjściowych
{
    echo "${NEW_HEADER}"
    cat "${TMP_GOOD_FILE}"
} > "${GOOD_OUTPUT_FILE}"

{
    echo "${HEADER}"
    cat "${TMP_BAD_FILE}"
} > "${BAD_OUTPUT_FILE}"


# Tworzenie tabeli CUSTOMERS_406342 w bazie MySQL
echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Creating CUSTOMERS_${INDEX} table in MySQL"
CREATE_TABLE_SQL="DROP TABLE IF EXISTS CUSTOMERS_${INDEX};
CREATE TABLE CUSTOMERS_${INDEX} (
    ProductKey INT,
    CurrencyAlternateKey VARCHAR(10),
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    OrderDateKey INT,
    OrderQuantity INT,
    UnitPrice DECIMAL(10,4),
	SecretCode VARCHAR(10)
);"

echo "$CREATE_TABLE_SQL" | mysql --local-infile=1 -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" "${MYSQL_DATABASE}" 2>/dev/null
if [[ $? -ne 0 ]]; then
    echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Creating CUSTOMERS_${INDEX} table in MySQL - Failed" | tee -a $LOG_FILE
    exit 1
else
    echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Creating CUSTOMERS_${INDEX} table in MySQL - Successful" >> $LOG_FILE
fi

# Załadowanie przefiltrowanych danych do tabeli CUSTOMERS_406342
LOAD_DATA_SQL="LOAD DATA LOCAL INFILE '${TMP_GOOD_FILE}' 
INTO TABLE CUSTOMERS_${INDEX}
FIELDS TERMINATED BY '|'
LINES TERMINATED BY '\n'
(ProductKey, CurrencyAlternateKey, FirstName, LastName, OrderDateKey, OrderQuantity, UnitPrice);"

echo "$LOAD_DATA_SQL" | mysql --local-infile=1 -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" "${MYSQL_DATABASE}" 2>/dev/null
if [[ $? -ne 0 ]]; then
    echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Loading data to CUSTOMERS_${INDEX} table - Failed" | tee -a $LOG_FILE
    exit 1
else
    echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Loading data to CUSTOMERS_${INDEX} table - Successful" >> $LOG_FILE
fi

# Uzupełnienie SecretCode losowym ciągiem znaków
UPDATE_SECRET_CODE_SQL="UPDATE CUSTOMERS_${INDEX}
SET SecretCode = SUBSTRING(MD5(RAND()), 1, 10);"
echo "$UPDATE_SECRET_CODE_SQL" | mysql -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" "${MYSQL_DATABASE}" 2>/dev/null
if [[ $? -ne 0 ]]; then
    echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Updating SecretCode in CUSTOMERS_${INDEX} table - Failed" | tee -a $LOG_FILE
    exit 1
else
    echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Updating SecretCode in CUSTOMERS_${INDEX} table - Successful" >> $LOG_FILE
fi

# Wyeksportowanie tabeli CUSTOMERS_406342 do pliku
echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Exporting MySQL table to csv file"
mysql -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" "${MYSQL_DATABASE}" -e "SELECT * FROM CUSTOMERS_${INDEX}" > "${EXPORT_FILE}" 2>/dev/null
if [[ $? -ne 0 ]]; then
    echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Exporting table CUSTOMERS_${INDEX} to CSV - Failed" | tee -a $LOG_FILE
    exit 1
else
    echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Exporting table CUSTOMERS_${INDEX} to CSV - Successful" >> $LOG_FILE
fi

# Skompresowanie pliku .csv
zip -q "${EXPORT_FILE%.csv}.zip" "${EXPORT_FILE}"

# Usunięcie plików tymczasowych
rm -f "${TMP_INPUT_FILE}" "${TMP_GOOD_FILE}" "${TMP_BAD_FILE}" "${SORTED_FILE}" "${CLEANED_FILE}"
if [[ $? -ne 0 ]]; then
  echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Deleting temporary files - Failed" | tee -a $LOG_FILE
else
  echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Deleting temporary files - Successful" >> $LOG_FILE
fi
echo "$(date +"%H:%M:%S.%2N %d-%m-%Y") - Script ran successfully"

