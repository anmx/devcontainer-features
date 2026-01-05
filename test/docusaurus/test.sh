
#!/bin/bash

set -e

source dev-container-features-test-lib

echo "Validating a Docusaurus serves on port 3000..."
CMD=$(cat <<EOF
curl --output /dev/null \
    --retry-connrefused \
    --retry-delay 1 \
    --retry 3 \
    --head \
    --fail \
    http://localhost:3000/
EOF
)
check "serves at default port 3000" bash -c "${CMD}"

#check "Docusaurus has been installed" bash -c "npm --silent --prefix ./Docusaurus run docusaurus -- --version |  grep '[7-8]\.[0-9]*\.[0-9]*'"

reportResults
