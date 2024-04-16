//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Encoding {
    function combineStrings() public pure returns(string memory) {
        return string(abi.encodePacked("Hi mom! ", "Miss you!")); 
        // like a compressor
        // concatenates strings, stores in bytes form (binary value), then typecasted to string
    }

    function encodeNumber() public pure returns(bytes memory) {
        bytes memory number = abi.encode(1); //returns how the computer will read the number 1
        return number;
    }

    function encodeString() public pure returns(bytes memory) {
        bytes memory someString = abi.encode("some string"); //the binary value has a lot of zeros that just take up space, thus, solidity offers encodePacked() which performs packed encoding of the given arguments.
        return someString;
    }

    function encodeStringPacked() public pure returns(bytes memory) {
        bytes memory someString = abi.encodePacked("some string");
        return someString;
    }

    function encodeStringBytes() public pure returns(bytes memory) {
        bytes memory someString = bytes("some string");
        return someString;
    }

    function decodeString() public pure returns(string memory) {
        string memory someString = abi.decode(encodeString(), (string)); //decodes from bytes to whatever datatype is passed as second parameter
        return someString;
    }

    function multiEncode() public pure returns(bytes memory) {
        bytes memory someString = abi.encode("some string", "it's bigger!"); //we can ask solidity to encode multiple values in one bytes value and also decode it
        return someString;
    }

    function multiDecode() public pure returns(string memory, string memory) {
        (string memory someString, string memory someOtherString) = abi.decode(multiEncode(), (string, string));
        return (someString, someOtherString);
    }

    function multiEncodePacked() public pure returns(bytes memory) {
        bytes memory someString = abi.encodePacked("some string ", "it's bigger!");
        return someString;
    }

    function multiDecodePacked() public pure returns(string memory) {
        string memory someString = abi.decode(multiEncodePacked(), (string));
        return someString;
    }

    function multiStringEncodePacked() public pure returns(string memory) {
        string memory someString = string(multiEncodePacked()); //typecasting can convert multi-encodePacked values, cannot use decode
        return someString;
    }
}

// GOTO NOTES.md for all notes