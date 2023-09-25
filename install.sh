echo "Foundry building..."
forge build
echo "Foundry built"

echo "Yarn installing for merkletree-tool..."
cd ./merkletree-tool && yarn install
cd ../
echo "Yarn installed"

echo "Yarn installing for app..."
cd ./app && yarn install
cd ../
echo "Yarn installed"
