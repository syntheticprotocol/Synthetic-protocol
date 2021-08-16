pragma solidity ^0.5.8;

import "./SafeMath.sol";

contract TRC20Events {
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
}

contract TRC20Basic is TRC20Events {
    function totalSupply() public view returns (uint theTotalSupply){}
    function balanceOf(address _owner) public view returns (uint balance){}
    function transfer(address _to, uint _value) public returns (bool success){}
    function transferFrom(address _from, address _to, uint _value) public returns (bool success){}
    function approve(address _spender, uint _value) public returns (bool success){}
    function allowance(address _owner, address _spender) public view returns (uint remaining){}
}

contract TRC20 is TRC20Basic {
    using SafeMath for uint;
    address payable public  owner;  //合约所有者
    address payable public  administrator;  //管理员

    string  public  name = "Synthetic Protocol";
    string  public  symbol = "SYN";
    uint8   public  decimals = 6;
    uint256 public  _totalSupply = 500000;

    mapping(address => uint256) public balances;  //余额
    mapping(address => mapping(address => uint256)) internal allowed;  //授权数量
    mapping(address => bool) public frozenAccount;  //冻结账户

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    //转账
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        require(!frozenAccount[_from] && !frozenAccount[_to]);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    //代币转账
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        require(!frozenAccount[_from] && !frozenAccount[_to]);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    //授权
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    //返回授权金额
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }


    //追加授权金额
    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    //撤销授权金额
    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}