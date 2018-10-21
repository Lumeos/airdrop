import pandas as pd

EOS_SNAPSHOT_FILE='eos_snapshot.csv'
TOKEN_MULTIPLIER=0.05 # How many airdropped tokens to send per EOS
OUTPUT_FILE='lume_snapshot.csv'
LUME_LIMIT=2000

ACCT_NAME_INDEX=1
EOS_INDEX=2
LUME_INDEX=3

df = pd.read_csv(EOS_SNAPSHOT_FILE, header=None)
df = df.drop(0, axis=1)
df[LUME_INDEX] = df[EOS_INDEX] * TOKEN_MULTIPLIER

# Blacklist
with open('blacklist.txt', 'r') as f:
    blacklist = f.read()
with open('whitelist.txt', 'r') as f:
    whitelist = f.read()
blacklist = [line.strip() for line in blacklist.split('\n') if line is not '' and line[0] is not '#']
whitelist = [line.strip() for line in whitelist.split('\n') if line is not '' and line[0] is not '#']
intersection = [pubkey for pubkey in whitelist if pubkey in blacklist]
assert len(intersection) == 0, "No keys in the whitelist should be in the blacklist: {0}".format(intersection)
df = df[~df[ACCT_NAME_INDEX].isin(blacklist)]

# apply limit
df[LUME_INDEX] = df[LUME_INDEX].map(lambda x: min(float(x), LUME_LIMIT))

# Decimal precision
df[LUME_INDEX] = df[LUME_INDEX].map(lambda x: '{0:.3f}'.format(x))
df[EOS_INDEX] = df[EOS_INDEX].map(lambda x: '{0:.4f}'.format(x))

df.to_csv(OUTPUT_FILE, index=False, header=False)
