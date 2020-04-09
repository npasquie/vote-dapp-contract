if lsof -Pi :8545 -sTCP:LISTEN -t >/dev/null ; then
    echo "ganache is running"
    truffle test
else
    echo "launching ganache : type 'yarn test' again in another terminal"
    ganache-cli
fi