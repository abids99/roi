const Roi = artifacts.require("Roi");
const ether = (n) => {
	return new web3.utils.BN(
		web3.utils.toWei(n.toString(), 'wei')
	)
}

require('chai')
	.use(require('chai-as-promised'))
	.should()

contract('Roi', ([owner, user1, user2]) => {
    const name = 'Interest Reward Token'
	const symbol = 'IRT'
	const decimals = '18'
    let roi


	beforeEach(async () => {
		roi = await Roi.new()
	})

    describe('deployment', () => {
		it('track the name', async () => {
			const result  = await roi.name()
			result.should.equal(name)
		})

		it('track the symbol', async () => {
			const result  = await roi.symbol()
			result.should.equal(symbol)
		})

		it('track the decimals', async () => {
			const result  = await roi.decimals()
			result.toString().should.equal(decimals)
		})

		it('track the Owner', async () => {
			const result  = await roi.owner()
			result.should.equal(owner)
		})
	})
	describe('registration', () => {
		let result
		beforeEach(async () => {
			let amount = ether(16900000000000000)
			result = await roi.aaregistration({ from: user1, value: amount })
			result2 = await roi.aaregistration({ from: user2, value: amount })
		})
		it('emits a register event', async () => {
			const log = result.logs[0]
			log.event.should.eq('Register')
			const event = log.args
			event._id.toString().should.equal('1', 'id is correct')
			event.addrss.should.equal(user1, 'user address is correct')
		})

		it('emits a register event2', async () => {
			
			const log = result2.logs[0]
			log.event.should.eq('Register')
			const event = log.args
			event._id.toString().should.equal('2', 'id is correct')
			event.addrss.should.equal(user2, 'user address is correct')
		})

	})
		
	
})