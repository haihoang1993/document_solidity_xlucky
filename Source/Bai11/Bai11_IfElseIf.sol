pragma solidity ^0.5.0;

contract SolidityTest {
    uint256 storedData; // State variable

    constructor() public {
        storedData = 10;
    }

    function getResult() public view returns (string memory) {
        uint256 a = 1;
        uint256 b = 2;
        uint256 c = 3;
        uint256 result;

        if (a > b && a > c) {
            // if else statement
            result = a;
        } else if (b > a && b > c) {
            result = b;
        } else {
            result = c;
        }
        return integerToString(result);
    }

    function integerToString(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;

        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;

        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr); //access local variable
    }
}

//Output
//0: string: 3
