// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface System {
    function versionCheck() external returns(uint);
    function errorCheck() external returns(bool);
    function boot() external returns(uint, bool);
}

contract Load{
    function versionCheck(address _addr) public returns(uint){
        return System(_addr).versionCheck();
    }
    function errorCheck(address _addr) public returns(bool){
        return System(_addr).errorCheck();
    }
    function boot(address _addr) public returns(uint, bool){
        return System(_addr).boot();
    }
}