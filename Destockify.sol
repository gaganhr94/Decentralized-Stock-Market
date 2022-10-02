pragma solidity 0.5.16;


contract Destockify {

    struct Ord_New
    {
        uint qntylft;  
        uint StateVar;
        address payable ExeAddr;
        uint Price;
        uint OrderOfID;
    }

    uint no_ord; 
    uint mktprice;

    string private Symbol; 
    mapping (address=> uint) private OwnStk; 
    
    Ord_New[] private sellord; 
    Ord_New[] private buyord; 


    Ord_New[] private tempord; 

    //function for IPO applications
    constructor(string memory symbol_sent, uint quantity_sent,uint price_sent) public
    {
        Symbol = symbol_sent;
        OwnStk[address(this)] = quantity_sent;
        sellord.push(Ord_New(no_ord,1,address(uint160(address(this))),price_sent,quantity_sent));
        no_ord++;
        mktprice = price_sent;
    }



    // function to sort selling orders 
    function sort_sellord() internal 
    {
        tempord.length = 0;
        for(uint i=0; i<sellord.length; i++)
        {
            uint found = 0;
            uint foundno = 0;
            for(uint j=0; j<sellord.length; j++)
            {
                if(sellord[j].StateVar == 1)
                {
                    if(found==0)
                    {
                        found = 1;
                        foundno = j;
                    }
                    else
                    {
                        if(sellord[foundno].Price > sellord[j].Price)
                        {
                            foundno = j;
                        }
                    }
                }
            }
            if(found == 1)
            {
                tempord.push(sellord[foundno]);
                sellord[foundno].StateVar = 0;
            }
        }

        sellord.length = 0;

        for(uint i = 0 ; i<tempord.length ; i++)
        {
            sellord.push(tempord[i]);
        }
        tempord.length = 0;
    }  

    // function to sort buyord
    function sort_buyord() internal 
    {
        tempord.length = 0;
        for(uint i=0; i<buyord.length; i++)
        {
            uint found = 0;
            uint foundno = 0;
            for(uint j=0; j<buyord.length; j++)
            {
                if(buyord[j].StateVar == 1)
                {
                    if(found==0){
                        found = 1;
                        foundno = j;
                    }
                    else{
                        if(buyord[foundno].Price < buyord[j].Price)
                        {
                            foundno = j;
                        }
                    }}}

            if(found == 1)
            {
                tempord.push(buyord[foundno]);
                buyord[foundno].StateVar = 0;
            }}

        buyord.length = 0;

        for(uint i = 0 ; i<tempord.length ; i++)
        {
            buyord.push(tempord[i]);
        }
        tempord.length = 0;
    } 


    function buy(uint sntprc, uint sent_qty) payable public
    {
        require(msg.value >= ((sntprc*sent_qty)*(1 wei)),"WRONG, amount of money paid"); // check if the value of money sent matches with quantity*price
        for(uint i=0;i<sellord.length;i++){
            if(sellord[i].Price > sntprc){
                break;
            }
            if(sellord[i].StateVar != 1){
                continue;
            }
            else
            {
                if(sellord[i].qntylft <= sent_qty){
                    mktprice = sntprc;
                    uint temp_qty = sellord[i].qntylft;
                    OwnStk[address(this)] -= temp_qty;
                    OwnStk[msg.sender] += temp_qty;
                    
                    if(sellord[i].ExeAddr != address(uint160(address(this))) ) {
                            sellord[i].ExeAddr.transfer(sntprc*temp_qty);
                    }

                    sellord[i].qntylft -= temp_qty;
                    if(sellord[i].qntylft == 0)
                    {
                        sellord[i].StateVar = 2;
                    }
                    sent_qty -= temp_qty;
                }
                else
                {
                    mktprice = sntprc;
                    uint temp_qty = sent_qty;
                    OwnStk[address(this)] -= temp_qty;
                    OwnStk[msg.sender] += temp_qty;
                    if(sellord[i].ExeAddr != address(uint160(address(this))) )
                    {
                        sellord[i].ExeAddr.transfer(sntprc*temp_qty);
                    }
                    sellord[i].qntylft -= temp_qty;
                    if(sellord[i].qntylft == 0)
                    {
                        sellord[i].StateVar = 2;
                    }
                    sent_qty -= temp_qty;
                }
            }
        }

        if(sent_qty > 0)
        {
            buyord.push(Ord_New(no_ord,1,msg.sender,sntprc,sent_qty));
            no_ord++;
        }
        sort_buyord();
        sort_sellord();
    }


    function sell(uint sell_price, uint sellqty) payable public
    {
        require(OwnStk[msg.sender] >= sellqty, "You do not have enough shares to sell");
        
        for(uint i=0;i<buyord.length;i++)
        {
            if(buyord[i].Price < sell_price)
            {
                break;
            }
            if(buyord[i].StateVar != 1){
                continue;
            }
            else
            {
                if(buyord[i].qntylft <= sellqty)
                {
                    mktprice = buyord[i].Price;
                    uint temp_qty = buyord[i].qntylft;
                    OwnStk[buyord[i].ExeAddr] += temp_qty;
                    OwnStk[msg.sender] -= temp_qty;
                    address(uint160(msg.sender)).transfer(buyord[i].Price*temp_qty);
                    buyord[i].qntylft -= temp_qty;
                    if(buyord[i].qntylft == 0)
                    {
                        buyord[i].StateVar = 2;
                    }
                    sellqty -= temp_qty;
                }
                else
                {
                    mktprice = buyord[i].Price;
                    uint temp_qty = sellqty;
                    OwnStk[buyord[i].ExeAddr] += temp_qty;
                    OwnStk[msg.sender] -= temp_qty;
                    address(uint160(msg.sender)).transfer(buyord[i].Price*temp_qty);
                    buyord[i].qntylft -= temp_qty;
                    if(buyord[i].qntylft == 0)
                    {
                        buyord[i].StateVar = 2;
                    }
                    sellqty -= temp_qty;
                }
                if(sellqty == 0){
                    break;
                }
            }
        }

        if(sellqty !=0)
        {
            sellord.push(Ord_New(no_ord,1,msg.sender,sell_price,sellqty));
            OwnStk[msg.sender] -= sellqty;
            OwnStk[address(this)] += sellqty;
            no_ord++;
        }
        sort_buyord();
        sort_sellord();
    }

    function getDetails(uint orderid) public view returns(string memory)
    {
        string memory ret = "";
        uint found = 0;
        for(uint i=0;i<buyord.length;i++){

            if(found == 0)
            {
            if(buyord[i].OrderOfID == orderid)
            {
                require(buyord[i].ExeAddr == msg.sender, "You are not the owner of this Buy order");
                ret = string(abi.encodePacked(ret,"\n-------------","\n","Order ID: ",uint2str(buyord[i].OrderOfID),"\n",
                "Price: ",uint2str(buyord[i].Price),"\n",
                "Quantity left: ", uint2str(buyord[i].qntylft),"\n",
                "StateVar: ",uint2str(buyord[i].StateVar),"\n"));
                
                found = 1;
                break;
            }}
        }

        for(uint i=0;i<sellord.length;i++){
            if(found == 0)
            {
            if(sellord[i].OrderOfID == orderid)
            {
                require(sellord[i].ExeAddr == address(uint160(msg.sender)), "You are not the owner of this Sell order");
                
                ret = string(abi.encodePacked(ret,"\n--------------------","\n","Order ID: ",uint2str(sellord[i].OrderOfID),"\n",
                "Price: ",uint2str(sellord[i].Price),"\n",
                "Quantity left: ", uint2str(sellord[i].qntylft),"\n",
                "StateVar: ",uint2str(sellord[i].StateVar),"\n"));
                
                found = 1;
                break;

            }
        }}

        if(found == 0)
        {
            ret = string("This Order ID you have provided does not exist, or the order is cancelled or fully executed");
        }
        return ret;
    }

    function getmktprice() public view returns(string memory)
    {
        string memory ret = "";
        ret = string(abi.encodePacked(ret,"\n  ","\n","Market Price: ",uint2str(mktprice),"\n"));
        return ret;
    }

    function getSymbol() public view returns(string memory)
    {
        return Symbol;
    }

    function getMarketDepth() public view returns(string memory)
    {
        string memory ret = "";
        uint length = 0;
        ret = string(abi.encodePacked(ret, "\n------------- SELL ORDERS------------\n"));
        uint i=0;
        uint itr = 0;
        while(i < sellord.length && itr < 5){
            if(sellord[i].StateVar == 1)
            {
                ret = string(abi.encodePacked(ret, "\nx) Price: ", uint2str(sellord[i].Price), "-> Shares: ", uint2str(sellord[i].qntylft), "\n"));
                itr++;
            }
            i++;
        }
        i = 0;
        itr = 0;
        ret = string(abi.encodePacked(ret, "\n\n------------BUY ORDERS-----------\n"));
        while(i < buyord.length && itr < 5){
            if(buyord[i].StateVar == 1)
            {
                ret = string(abi.encodePacked(ret, "\nx) Price: ", uint2str(buyord[i].Price), "-> Shares: ", uint2str(buyord[i].qntylft), "\n"));
                itr++;
            }
            i++;
        }
        return ret;
    }
    function getActiveOrders() public view returns(string memory){
        string memory ret = "";
        uint length = 0;
        ret = string(abi.encodePacked(ret, "\n-------------SELL ORDERS------------\n"));
        for(uint i=0;i<sellord.length;i++)
        {
            if(sellord[i].StateVar == 1 && sellord[i].ExeAddr == address(uint160(msg.sender)))
            {
                ret = string(abi.encodePacked(ret,"\n--------------------","\n","Order ID: ",uint2str(sellord[i].OrderOfID),"\n",
                "Price: ",uint2str(sellord[i].Price),"\n",
                "Quantity left: ", uint2str(sellord[i].qntylft),"\n",
                "StateVar: ",uint2str(sellord[i].StateVar),"\n"));
            }
        }
        ret = string(abi.encodePacked(ret, "\n\n-------------BUY ORDERS------------\n\n"));
        for(uint i=0;i<buyord.length;i++)
        {
            if(buyord[i].StateVar == 1 && buyord[i].ExeAddr == address(uint160(msg.sender)))
            {
                ret = string(abi.encodePacked(ret,"\n---------------------","\n","Order ID: ",uint2str(buyord[i].OrderOfID),"\n",
                "Price: ",uint2str(buyord[i].Price),"\n",
                "Quantity left: ", uint2str(buyord[i].qntylft),"\n",
                "StateVar: ",uint2str(buyord[i].StateVar),"\n"));
            }
        }
        return ret;
    }
    function cancel_buyorder(uint orderid) public payable
    {
        uint found = 0;
        for(uint i=0;i<buyord.length;i++)
        {
            if(buyord[i].OrderOfID == orderid)
            {
                require(buyord[i].ExeAddr == address(uint160(msg.sender)), "You are not the owner of this Buy order");
                require(buyord[i].StateVar == 1, "The Order is already cancelled or fulfilled");
                buyord[i].ExeAddr.transfer(buyord[i].Price*buyord[i].qntylft);
                buyord[i].StateVar = 0;
                found = 1;
                break;

            }
        }
        require(found == 1,"This Order ID you have provided does not exist, please recheck");
        sort_buyord();
    }

    function cancel_sellorder(uint orderid) public 
    {
        uint found = 0;
        for(uint i=0;i<sellord.length;i++)
        {
            if(sellord[i].OrderOfID == orderid)
            {
                require(sellord[i].ExeAddr == msg.sender, "You are not the owner of this Sell order");
                require(sellord[i].StateVar == 1, "The Order is already cancelled or fulfilled");
                sellord[i].StateVar = 0;
                OwnStk[msg.sender] += sellord[i].qntylft;
                OwnStk[address(this)] -= sellord[i].qntylft;
                found = 1;
                break;

            }
        }
        require(found == 1,"This Order ID you have provided does not exist, please recheck");
        sort_sellord();
    }
    function getShares() view public returns(string memory) 
    {
        string memory ret = "";
        ret = string(abi.encodePacked(ret,"\n   ","\n","Your shares: ",uint2str(OwnStk[msg.sender]),"\n"));
        return ret;
    }

    function uint2str(uint256 _i) internal pure returns (string memory str)
    {
        if (_i == 0)
        {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0)
        {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0)
        {
            bstr[--k] = bytes1(uint8(48 + j % 10));
            j /= 10;
        }
        str = string(bstr);
    }
}