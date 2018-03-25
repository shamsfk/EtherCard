const HDWalletProvider = require('truffle-hdwallet-provider')
const Web3 = require('web3')
const fs = require('fs-extra')
const path = require('path')

const accountInfo = require(path.resolve(__dirname, 'account.info.json'))

console.log('Deployment process will use account info:')
console.log(accountInfo)

const provider = new HDWalletProvider(
  accountInfo.mneumonic,
  accountInfo.link
)
const web3 = new Web3(provider)

const compiledContract = require(path.resolve(__dirname, 'build', 'EtherCard.json'))

const deploy = async () => {
  const accounts = await web3.eth.getAccounts()

  console.log('Attempting to deploy from account', accounts[0])

  const result = await new web3.eth.Contract(
    JSON.parse(compiledContract.interface)
  )
    .deploy({ data: compiledContract.bytecode })
    .send({ gas: '1000000', from: accounts[0] })

  console.log('Contract deployed to', result.options.address)

  fs.appendFileSync(path.resolve(__dirname, 'deployaddr.txt'), getDateTime() + ' - ' + result.options.address + '\n', (err) => {
    console.log(err)
  })
}
deploy()

// TODO: change to some npm module
function getDateTime () {
  var date = new Date()

  var hour = date.getHours()
  hour = (hour < 10 ? '0' : '') + hour

  var min = date.getMinutes()
  min = (min < 10 ? '0' : '') + min

  var sec = date.getSeconds()
  sec = (sec < 10 ? '0' : '') + sec

  var year = date.getFullYear()

  var month = date.getMonth() + 1
  month = (month < 10 ? '0' : '') + month

  var day = date.getDate()
  day = (day < 10 ? '0' : '') + day

  return year + ':' + month + ':' + day + ':' + hour + ':' + min + ':' + sec
}
