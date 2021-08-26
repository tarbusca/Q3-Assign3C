/**
Assignment 3C
1. Owner can transfer the ownership of the Token Contract.
2. Owner can approve or delegate anybody to manage the pricing of tokens.
3. Update pricing method to allow owner and approver to change the price of the token
3. Add the ability that Token Holder can return the Token and get back the Ether based on the current price.
 */
pragma solidity ^0.8.0;
//"SPDX-License-Identifier: UNLICENSED"

/**
 * Tariq Saeed 
 * PIAIC 111569
 */
 
//if you run these in Remix, the imports will work.
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TariqToken3B is Ownable, ERC20 {
    uint256 private curSupply;
    uint256 private tokenCap = 2000000*(10**decimals());    //3B.1
    uint256 private contractBirthday;
    uint256 public constant MINIMUM_DELAY = 0; //30 days; setting to zero so that token transfer can be tested
    uint24  private curRate;
    mapping(address => bool) private priceApprovers;
    
    constructor (string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000*(10**decimals()));
        contractBirthday = block.timestamp;  //3B.2
         curRate = 100;  //setting current conversion of ether to token
         priceApprovers[msg.sender] = true;
    }

        fallback() external payable {
                    if (msg.value > 0 ) {
            _mint(msg.sender, msg.value * curRate);
        } 
        }
        receive() external payable{}
    //3C.2    
    modifier priceAppr() { 
        require(priceApprovers[msg.sender], "Either Owner or Approver can call this function");
        _; 
        
    }
    //3B.1 Shows the toal cap of token  
        function cap() public view virtual returns (uint256) {
        return tokenCap;
    }
        function mint(address account, uint256 amount) public {
        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: Token Cap exceeded");
        _mint(account, amount);
    }
    //3B.2
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        require(block.timestamp > contractBirthday + MINIMUM_DELAY);
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    //3A
    function buyToken () payable external {
        mint(msg.sender, msg.value*curRate);
    }
    //3A. There should be an additional method to adjust the price that allows the owner to adjust the price.
    function priceAdjust (uint24 _rate) public priceAppr() {
        curRate = _rate;
        
    }     // 3C.3 The user can return the tokens based on current rate
     function returnToken (uint256 _tokens) external {
        uint256 curValue;
        require(_tokens <= balanceOf(msg.sender), "Insufficient Balance for Withdrawl of tokens");
        curValue = _tokens/curRate;
        transfer(owner(), _tokens);
        payable(msg.sender).transfer(curValue);
        
    } //3A
    function viewCurRate() public view returns (uint256) {
    return curRate;
    }    
    function contractEthers() public view returns (uint256){
        return address(this).balance;
    }
    //3C.2 delegating Price Approval to new user
    function delegatePriceApproval(address _approver) external onlyOwner {
        priceApprovers[_approver] = true;
    }
    //3C.2 Revoking approval from existing user
    function revokePriceApproval(address _approver) external onlyOwner {
        require(priceApprovers[_approver], "The user doesn't exist or already been revoked");
        priceApprovers[_approver] = false;
    }
}
