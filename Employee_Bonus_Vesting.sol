

/* This smart contract allows an employer to set up a bonus vesting schedule for their new hires. 
After one year, the bonus will be made available to the employee for withdrawal.
Only the designated employer (owner) can deposit money for the employee.
Only the specific employee can withdraw their own money.
*/

//SPDX-License_identifier: UNLICENSED

pragma solidity ^0.8.7;

contract CryptoBonusVesting {
    //owner Dad

    address owner;

    event logEmployeeHired (address addr, uint amount, uint contractBalance);

    constructor () {
        owner = msg.sender;
    }

        //define employee

    struct Employee {
        address payable walletAddress;
        string firstName;
        string lastName;
        uint hiredTime;
        uint amountCanWithdraw;
        bool fullyVested;
        bool isEmployed;

    }

    Employee[] public employees;

    modifier onlyOwner () {
        require(msg.sender == owner, "Only the owner can do this!");
        _;
    }
    //add employee to contract
    function addEmployee(address payable walletAddress, string memory firstName, string memory lastName, uint hiredTime, uint amountCanWithdraw, bool fullyVested, bool isEmployed) public onlyOwner {
        
        employees.push( Employee( walletAddress,
        firstName,
        lastName,
        hiredTime,
        amountCanWithdraw,
        fullyVested,
        isEmployed));

    }

    //get balance
    function getBalance ()  public view returns (uint){
        return address(this).balance;
    }

     //deposit funds to contract, to a specific employee's account
    function deposit(address walletAddress) public payable {
        addToEmployeesBalance(walletAddress);
    }

    function addToEmployeesBalance (address walletAddress) private {
        for (uint i = 0; i < employees.length; i++){
            if (employees[i].walletAddress == walletAddress){
            employees[i].amountCanWithdraw += msg.value;
            emit logEmployeeHired (walletAddress, msg.value, getBalance());
            }
        }
    }
   

    function getIndex (address walletAddress) view private returns (uint) {
        for (uint i = 0; i < employees.length; i++){
            if (employees[i].walletAddress == walletAddress){
            return i;
            }
        }
            return 999;
    }
    //check if employee can withdraw

    function availableToWithdraw(address walletAddress) public returns(bool) {
        uint i = getIndex(walletAddress);
        require(block.timestamp > (employees[i].hiredTime + 31536000), "It's not time yet - you need to be currently employed and here for one year.");
        if (block.timestamp >= (employees[i].hiredTime + 31536000)) {
            if (employees[i].isEmployed == true ) {
            employees[i].fullyVested = true;
        }
        }
        else{
            employees[i].fullyVested = false;
        }
        return employees[i].fullyVested;

    }

    function EmployeeLeftCompany (address walletAddress) public {
         uint i = getIndex(walletAddress);
         employees[i].isEmployed = false;
    }

    //withdraw money

    function withdraw (address payable walletAddress) payable public {
        
        uint i = getIndex (walletAddress);
        require(msg.sender == employees[i].walletAddress, "you must be the employee to withdraw");
        require(employees[i].isEmployed == true, "You don't work here anymore!");
        require(employees[i].fullyVested == true, "You can't withdraw yet - it hasn't been a year");
        employees[i].walletAddress.transfer(employees[i].amountCanWithdraw);
      
    }
}