
const path = require('path');
const fs = require('fs');
const solc = require('solc');

const CONTRACTS_DIR = path.resolve(__dirname, 'contracts');

function findContract(pathName) {
    const contractPath = path.resolve(CONTRACTS_DIR, pathName);
    if (isContract(contractPath)) {
        return fs.readFileSync(contractPath, 'utf8');
    } else {
        throw new Error(`File ${contractPath} not found`);
    }
}

function isContract(path) {
    return fs.existsSync(path);
}

function findImports (pathName) {
    try {
        return { contents: findContract(pathName) };
    } catch(e) {
        return { error: e.message };
    }
}

const source = findContract('EtherCard.sol');
const compiled = solc.compile({
    sources: {
        'EtherCard' : source
    }
}, 1, findImports);

module.exports = compiled.contracts['EtherCard:EtherCard'];