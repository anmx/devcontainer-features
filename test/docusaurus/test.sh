
#!/bin/bash

set -e

source dev-container-features-test-lib

echo "Validating a Docusaurus version present..."
check "Docusaurus has been installed" bash -c "npm --silent --prefix ./Docusaurus run docusaurus -- --version |  grep '[7-8]\.[0-9]*\.[0-9]*'"

reportResults