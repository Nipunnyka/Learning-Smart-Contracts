// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;


contract DeadManSwitch {
    address public owner;
    uint public lastAliveBlock;
    address payable public backupAccount;

    constructor(address payable _backupAccount) {
        owner = msg.sender;
        backupAccount = _backupAccount;
        lastAliveBlock = block.number;
    }

    receive() external payable {}
    fallback() external payable {}

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    modifier isOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function still_alive() public isOwner {
        lastAliveBlock = block.number;
    }

    function killSwitch() public {
        if(lastAliveBlock + 10 < block.number){
            uint amount = address(this).balance;

            (bool sent, bytes memory data) = backupAccount.call{value: amount}("");
            require(sent, "Failed to send Ether");
        }
    }

}
