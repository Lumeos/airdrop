SYMBOL="LUME"
ISSUER="lumeostokens"
VALIDATIONS=2
SNAPSHOT_FILE=lume_snapshot.csv

NUM_LINES=$(wc -l "${SNAPSHOT_FILE}" | awk '{print $1}')
FAIL_FLAG=false
for i in `seq 1 $VALIDATIONS`; do
    RAND=$(openssl rand 4 | od -DAn)
    RAND=$((RAND % $NUM_LINES))
    LINE=$(sed "${RAND}q;d" "${SNAPSHOT_FILE}")
    ACCOUNT=$(echo $line | tr "," "\n" | head -1 | tail -1)
    AMOUNT=$(echo $line | tr "," "\n" | tail -1)
    CURRENT_BALANCE=$(cl get table $ISSUER $ACCOUNT accounts | grep $SYMBOL | grep -Eo '[0-9]+\.[0-9]+')
    #echo "$ACCOUNT $AMOUNT $CURRENT_BALANCE"
    if [ "$AMOUNT" != "$CURRENT_BALANCE" ]; then
        echo "$ACCOUNT failed. Should have $AMOUNT $SYMBOL"
        FAIL_FLAG=true
    fi
done
if [ $FAIL_FLAG = "false" ]; then
    echo "All Tests Passed"
fi
