#!/bin/bash

SYMBOL="LUME"
ISSUER="lumeostokens"
SNAPSHOT_FILE="lume_snapshot.csv"

echo "Creating token..."
CREATED=$(cl get table $ISSUER $SYMBOL stat | grep $SYMBOL)
if [[ -z $CREATED ]]; then
    echo "Creating..."
    cl push action $ISSUER create "[\"$ISSUER\", \"100000000000.000 $SYMBOL\"]" -p $ISSUER@active
else
    echo "Token exists. Skipping create"
fi

ISSUANCE=$(cl get table $ISSUER $ISSUER accounts | grep $SYMBOL)
if [[ -z $ISSUANCE ]]; then
    echo "Issuing..."
    cl push action $ISSUER issue "[\"$ISSUER\", \"10000000000.000 $SYMBOL\", \"initial supply\"]" -p $ISSUER@active
else
    echo "Token already issued. Skipping issue"
fi

for line in $(cat $SNAPSHOT_FILE); do
    ACCOUNT=$(echo $line | tr "," "\n" | head -1 | tail -1)
    AMOUNT=$(echo $line | tr "," "\n" | tail -1)
    CURRENT_BALANCE=$(cl get table $ISSUER $ACCOUNT accounts | grep $SYMBOL)
    if [[ -z $CURRENT_BALANCE ]]; then
        echo "Airdropping $AMOUNT $SYMBOL to $ACCOUNT"
        cl push action $ISSUER transfer "[\"$ISSUER\", \"$ACCOUNT\", \"$AMOUNT $SYMBOL\", \"airdrop\"]" -p $ISSUER@active
    else
        echo "Skipping $ACCOUNT"
    fi
done

