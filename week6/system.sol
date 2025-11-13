// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface System {
    function versionCheck() external returns(uint);
    function errorCheck() external returns(bool);
    function boot() external returns(uint, bool);
}

contract Computer is System{
    function versionCheck() public pure override returns(uint){
        return 3;
    }
    function errorCheck() public pure override returns(bool){
        return true;
    }
    function boot() public pure override returns(uint, bool){
        return (versionCheck(), errorCheck());
    }
}
