// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract Roi is ERC20, Ownable{
    using SafeMath for uint256;
    
    address constant zero = address(0);
    
    
    uint256 fee;
    uint256 id;
    uint256 did;
    uint256 userCount;
    uint256 liquifyLimit = 1000000000000000000;

    mapping(uint256 => address) public user;
    mapping(address => uint256) internal userInterest;
    mapping(address => uint256) internal depositAmount;
	mapping(address => uint256) public balance;
    mapping(address => uint256) internal timeOfTransfer;
    mapping(uint256 => uint256) internal didm;
    
    event Register(uint256 id, address user);
    event Deregister(uint256 id, address addrss);    
    event Deposit(uint256 id, address user, uint256 amount, uint256 balance);
    event Withdraw(uint256 id, address user, uint256 amount, uint256 balance);
    event Interest(uint256 id, address user, uint256 day, uint256 amount);
    event Liquify(uint256 numberOfUsers, uint256 amount);
    event LiquifyWithAddress(uint256 numberOfUsers, address user, uint256 amount);

    constructor () ERC20("Interest Reward Token", "IRT") Ownable() {
        id = 0;
        did = 1;
        userCount = 0;
        user[id] = msg.sender;
    }

    function registration () payable public {
        require(msg.sender != owner(), 'Error, YOU ARE OWNER');
        uint256 li;
        for (li = 0; li <= did; li++) {
            if (didm[li] > 0) {
                id = didm[li]; break;
            } else {
                id = userCount.add(1);
            }
        }

        require(user[id] == zero, 'Error, this id is already registerer');

        for (uint256 i = 1; i <= userCount; i++) {
            require(msg.sender != user[i], 'Error, this address is already registerer');
        }

        require(msg.value == 16900000000000000 wei, 'Error, registration fee is 16900000000000000 WEI');

        fee = fee.add(msg.value);

        user[id] = msg.sender;

        userCount++;
        
        liquify();

        didm[li] = 0;

        emit Register(id, user[id]);

    }

    function deregistration (uint256 _id) payable public {
        require(msg.sender == user[_id], 'Error, You are NOT registerer');
        require(user[0] != user[_id]);

        uint256 ldid;
        address deUser = user[_id];

        if (balance[user[_id]] > 0) {
            withdraw(_id, balance[user[_id]]);
        }

        user[_id] = zero;

        if (did > ldid) {
            didm[did] = _id;
        }

        ldid = did;
        
        did++;

        userCount = userCount.sub(1);

        emit Deregister(_id, deUser);
    }

    function liquidityAmount () view internal returns (uint256) {
        uint256 a = fee;
        uint256 b = 67;
        uint256 c = 100;
        uint256 d = a.mul(b).div(c);
        uint256 e = d.div(userCount);

        return e;
    }

    function liquify () internal {
        if (fee >= liquifyLimit) {
            uint256 lAmount = liquidityAmount();

            for (uint256 i = 1; i <= userCount; i++ ) {
                
                payable(user[i]).transfer(lAmount);

                fee = fee.sub(liquidityAmount());
                
                emit LiquifyWithAddress(i, user[i], lAmount);
            }
            
            emit Liquify(userCount, lAmount.mul(userCount));
        }
    }

    function deposit (uint256 _id) payable public {
        require(msg.sender == user[_id], 'Error, You are NOT registerer');
        require(msg.value > 0);

        msg.value;
        
        if(timeOfTransfer[user[_id]] > 0) {
            _interest(_id);
            balance[user[_id]] = balance[user[_id]].add(msg.value);
            depositAmount[user[_id]] = depositAmount[user[_id]].add(msg.value);
            timeOfTransfer[user[_id]] = block.timestamp;
        } else {
            balance[user[_id]] = balance[user[_id]].add(msg.value);
            depositAmount[user[_id]] = depositAmount[user[_id]].add(msg.value);
            timeOfTransfer[user[_id]] = block.timestamp;
        }
        emit Deposit(_id, user[_id], msg.value, balance[user[_id]]);
	}

    function day (uint256 _id) view public returns (uint256) {
        uint256 result;

        if(balance[user[_id]] > 0){
            uint256 currentTime = block.timestamp;
        
            uint256 timeGap = currentTime.sub(timeOfTransfer[user[_id]]);

            result = timeGap.div(86400); // 86400 seconds in 1 day                 
        } else {
            result = 0;
        }

        return result;
    }

    function interest (uint256 _id) view public returns (uint256) {
        uint256 interestRateAmount;
        
        if (balance[user[_id]] > 0) {
            uint256 amount;
            uint256 _day = day(_id);

            for(uint256 i = 1; i <= _day; i++){
            uint256 ratePercent = 171;

            amount = balance[user[_id]].mul(ratePercent).div(10000);
            
            interestRateAmount = interestRateAmount.add(amount);
            }

            interestRateAmount = interestRateAmount.sub(depositAmount[user[_id]]);
        
        } else {
            interestRateAmount = 0;
        }

        return interestRateAmount;
    }

    function _interest (uint256 _id) internal {
        uint256 amount = interest(_id);
        
        userInterest[user[_id]] = userInterest[user[_id]].add(amount);
        
        balance[user[_id]] = balance[user[_id]].add(amount);

        emit Interest(_id, user[_id], day(_id), amount);
    }

    function withdraw (uint256 _id, uint256 _amount) public {
        require(_amount <= balance[user[_id]]);
        require(msg.sender == user[_id], 'Error, You are NOT the person');
        
        if (day(_id) > 0) {
            _interest(_id);

            mint(_id, _amount); 
        }

        timeOfTransfer[user[_id]] = block.timestamp; 
        
        depositAmount[user[_id]] = depositAmount[user[_id]].sub(_amount);

        payable(user[_id]).transfer(_amount);

        emit Withdraw(_id, user[_id], _amount, balance[user[_id]]);
    }

    function mint (uint256 _id, uint256 _amount) internal {
        require(userInterest[user[_id]] > 0);
        
        uint256 mintable = userInterest[user[_id]];

        _mint(user[_id], mintable);

        userInterest[user[_id]] = userInterest[user[_id]].sub(mintable);
        
        balance[user[_id]] = balance[user[_id]].sub(_amount.add(mintable));
    }

    function rewards (address usr) view public returns (uint256) {
        uint256 r;
        r = balanceOf(usr);
        return r;
    }

}