pragma solidity ^0.8.0;

contract PlatformDec
{
    mapping (address => bool) isCompany;
    mapping (string => address payable) companyNames;
    mapping (address => uint256) companyStocksList;
    mapping (address => uint256) companyStockPrices;

    function registerCompany(string memory stockName) public payable
    {
        companyNames[stockName] = payable(msg.sender);
        isCompany[msg.sender] = true;
    }

    modifier checkCompany(address addr)
    {
        require(isCompany[addr] == true, "Invalid company");
        _;
    }

    function updateCompanyStocks(uint256 _quantity, uint256 _price) public payable checkCompany(msg.sender)
    {
        companyStocksList[msg.sender] = _quantity;
        companyStockPrices[msg.sender] = _price;
    }

    
    modifier priceCheck(string memory companyName)
    {
        require(msg.value == (companyStockPrices[companyNames[companyName]])*(1 ether), "Not enough cash or too much cash");
        _;
    }

    modifier quantityCheck(string memory companyName, uint256 _quantity)
    {
        require(_quantity <= companyStocksList[companyNames[companyName]], "You are asking for more stocks than available");
        _;
    }

    function BuyOneStock(string memory companyName) public payable priceCheck(companyName) checkCompany(companyNames[companyName])
    {
        companyNames[companyName].transfer(companyStockPrices[companyNames[companyName]] * (1 ether));
        companyStocksList[companyNames[companyName]]--;
    }

    function BuyMultipleStocks(string memory companyName, uint256 _quantity) public payable checkCompany(companyNames[companyName]) quantityCheck(companyName, _quantity)
    {
        for(uint i = 1; i <= _quantity; i++)
        {
            BuyOneStock(companyName);
        }
    }
    
}