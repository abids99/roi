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
    mapping(address => uint256) internal depositAmount;
	mapping(address => uint256) public balance;
    mapping(address => uint256) internal timeOfTransfer;
    mapping(uint256 => uint256) internal didm;
    
    event Register(uint256 id, address addrss);
    event Deregister(uint256 id, address addrss);    
    event Deposit(uint256 id, address depositor, uint256 amount, uint256 balance);
    event Withdraw(uint256 id, address withdrawer, uint256 amount, uint256 balance);
    event Interest(uint256 id, address addrss, uint256 day, uint256 amount);
    event Liquify(uint256 numberOfUsers, uint256 amount);
    event LiquifyWithAddress(uint256 numberOfUsers, address usr, uint256 amount);

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
        
        uint256 _id = id;

        fee = fee.add(msg.value);

        user[id] = msg.sender;

        userCount++;
        
        liquify();

        didm[li] = 0;

        emit Register(_id, user[_id]);

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

    function userCountShow () view public returns (uint256) {
        return userCount;
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

    function contBal () view public returns (uint256) {
        return address(this).balance;
    }

    function day (uint256 _id) view public returns (uint256) {
        uint256 currentTime = block.timestamp;
        uint256 timeGap = currentTime.sub(timeOfTransfer[user[_id]]);
        uint256 result = timeGap.div(10); // 86400 seconds in 1 day
        return result;
    }

    function interest (uint256 _id) view public returns (uint256) {
        uint256 amount;
        uint256 _day = day(_id);
        uint256 interestTestAmount = balance[user[_id]];

        for(uint256 i = 1; i <= _day; i++){
            uint256 ratePercent = 171;
            
            amount = interestTestAmount.mul(ratePercent).div(10000);
            interestTestAmount = interestTestAmount.add(amount);
        }
        interestTestAmount = interestTestAmount.sub(depositAmount[msg.sender]);
        return interestTestAmount;
    }

    function _interest (uint256 _id) internal {
        uint256 amount = interest(_id);

        balance[user[_id]] = balance[user[_id]].add(amount);

        emit Interest(_id, user[_id], day(_id), amount);
    }

    function withdraw(uint256 _id, uint256 _amount) payable public {
        require(_amount <= balance[user[_id]]);
        require(msg.sender == user[_id], 'Error, You are NOT registerer');
        
        if (day(_id) > 0) {
            _interest(_id);
        }

        uint256 mintable = balance[user[_id]].sub(depositAmount[user[_id]]);

        timeOfTransfer[user[_id]] = block.timestamp;

        balance[user[_id]] = balance[user[_id]].sub(_amount.add(mintable));

        _mint(user[_id], mintable);
        
        depositAmount[user[_id]] = depositAmount[user[_id]].sub(_amount);

        payable(user[_id]).transfer(_amount);

        emit Withdraw(_id, user[_id], _amount, balance[user[_id]]);
    }

    function rewards (address usr) view public returns (uint256) {
        uint256 r;
        r = balanceOf(usr);
        return r;
    }

}