// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice Mock contract for testing code size monitoring
/// @dev This contract can be deployed with different amounts of code to simulate code size changes
contract MockTargetContract {
    uint256 public value;
    string public name;
    mapping(address => uint256) public balances;

    constructor() {
        value = 100;
        name = "MockTarget";
    }

    function setValue(uint256 _value) external {
        value = _value;
    }

    function setName(string memory _name) external {
        name = _name;
    }

    function setBalance(address _addr, uint256 _balance) external {
        balances[_addr] = _balance;
    }

    function getValue() external view returns (uint256) {
        return value;
    }

    function getName() external view returns (string memory) {
        return name;
    }

    // Additional functions to increase code size
    function function1() external pure returns (uint256) {
        return 1;
    }

    function function2() external pure returns (uint256) {
        return 2;
    }

    function function3() external pure returns (uint256) {
        return 3;
    }
}

/// @notice Mock contract with larger code size for testing
contract MockTargetContractLarge {
    uint256 public value;
    string public name;
    mapping(address => uint256) public balances;
    mapping(address => bool) public isActive;
    mapping(address => mapping(address => uint256)) public allowances;

    constructor() {
        value = 200;
        name = "MockTargetLarge";
    }

    function setValue(uint256 _value) external {
        value = _value;
    }

    function setName(string memory _name) external {
        name = _name;
    }

    function setBalance(address _addr, uint256 _balance) external {
        balances[_addr] = _balance;
    }

    function setActive(address _addr, bool _active) external {
        isActive[_addr] = _active;
    }

    function setAllowance(address _owner, address _spender, uint256 _amount) external {
        allowances[_owner][_spender] = _amount;
    }

    // Many additional functions to increase code size significantly
    function function1() external pure returns (uint256) { return 1; }
    function function2() external pure returns (uint256) { return 2; }
    function function3() external pure returns (uint256) { return 3; }
    function function4() external pure returns (uint256) { return 4; }
    function function5() external pure returns (uint256) { return 5; }
    function function6() external pure returns (uint256) { return 6; }
    function function7() external pure returns (uint256) { return 7; }
    function function8() external pure returns (uint256) { return 8; }
    function function9() external pure returns (uint256) { return 9; }
    function function10() external pure returns (uint256) { return 10; }
    function function11() external pure returns (uint256) { return 11; }
    function function12() external pure returns (uint256) { return 12; }
    function function13() external pure returns (uint256) { return 13; }
    function function14() external pure returns (uint256) { return 14; }
    function function15() external pure returns (uint256) { return 15; }
    function function16() external pure returns (uint256) { return 16; }
    function function17() external pure returns (uint256) { return 17; }
    function function18() external pure returns (uint256) { return 18; }
    function function19() external pure returns (uint256) { return 19; }
    function function20() external pure returns (uint256) { return 20; }
}
