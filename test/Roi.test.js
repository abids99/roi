const Roi = artifacts.require("Roi");
const ether = (n) => {
	return new web3.utils.BN(
		web3.utils.toWei(n.toString(), 'wei')
	)
}

require('chai')
	.use(require('chai-as-promised'))
	.should()

contract('Roi', ([owner, user1, user2, user3, user4, user5, user6, user7, user8, user9, user10, user11, user12, user13, user14, user15, user16, user17]) => {
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
			result1 = await roi.registration({ from: user1, value: amount })
			result2 = await roi.registration({ from: user2, value: amount })
			result3 = await roi.registration({ from: user3, value: amount })
			result4 = await roi.registration({ from: user4, value: amount })
			result5 = await roi.registration({ from: user5, value: amount })
			result6 = await roi.registration({ from: user6, value: amount })
			result7 = await roi.registration({ from: user7, value: amount })
			result8 = await roi.registration({ from: user8, value: amount })
			result9 = await roi.registration({ from: user9, value: amount })
		})
		it('emits a register event', async () => {
			const log = result1.logs[0]
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

		it('emits a register event3', async () => {
			
			const log = result3.logs[0]
			log.event.should.eq('Register')
			const event = log.args
			event._id.toString().should.equal('3', 'id is correct')
			event.addrss.should.equal(user3, 'user address is correct')
		})

		it('emits a register event4', async () => {
			
			const log = result4.logs[0]
			log.event.should.eq('Register')
			const event = log.args
			event._id.toString().should.equal('4', 'id is correct')
			event.addrss.should.equal(user4, 'user address is correct')
		})

		it('emits a register event5', async () => {
			
			const log = result5.logs[0]
			log.event.should.eq('Register')
			const event = log.args
			event._id.toString().should.equal('5', 'id is correct')
			event.addrss.should.equal(user5, 'user address is correct')
		})

		it('emits a register event6', async () => {
			
			const log = result6.logs[0]
			log.event.should.eq('Register')
			const event = log.args
			event._id.toString().should.equal('6', 'id is correct')
			event.addrss.should.equal(user6, 'user address is correct')
		})

		it('emits a register event7', async () => {
			
			const log = result7.logs[0]
			log.event.should.eq('Register')
			const event = log.args
			event._id.toString().should.equal('7', 'id is correct')
			event.addrss.should.equal(user7, 'user address is correct')
		})

		it('emits a register event8', async () => {
			
			const log = result8.logs[0]
			log.event.should.eq('Register')
			const event = log.args
			event._id.toString().should.equal('8', 'id is correct')
			event.addrss.should.equal(user8, 'user address is correct')
		})

		it('emits a register event9', async () => {
			
			const log = result9.logs[0]
			log.event.should.eq('Register')
			const event = log.args
			event._id.toString().should.equal('9', 'id is correct')
			event.addrss.should.equal(user9, 'user address is correct')
		})
		
	})
		
})