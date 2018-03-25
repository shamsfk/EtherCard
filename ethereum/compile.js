const path = require('path')
const fs = require('fs-extra')
const solc = require('solc')

console.log('compilation of ethereum contracts...')

const CONTRACTS_DIR = path.resolve(__dirname, 'contracts')

function findContract (pathName) {
  const contractPath = path.resolve(CONTRACTS_DIR, pathName)
  if (isContract(contractPath)) {
    return fs.readFileSync(contractPath, 'utf8')
  } else {
    throw new Error(`File ${contractPath} not found`)
  }
}

function isContract (path) {
  return fs.existsSync(path)
}

function findImports (pathName) {
  try {
    return { contents: findContract(pathName) }
  } catch (e) {
    return { error: e.message }
  }
}

const source = findContract('EtherCard.sol')
const output = solc.compile({
  sources: {
    'EtherCard.sol': source
  }
}, 1, findImports).contracts

const buildPath = path.resolve(__dirname, 'build')
fs.removeSync(buildPath)
fs.ensureDirSync(buildPath)

console.log(`exporting ${Object.keys(output).length} contracts:`)
for (let contract in output) {
  console.log('  ' + contract.substring(0, contract.indexOf(':')))
  fs.outputJsonSync(
    path.resolve(buildPath, contract.substring(contract.indexOf(':') + 1) + '.json'), output[contract]
  )
}
console.log('done')

module.exports = output['EtherCard.sol:EtherCard']
