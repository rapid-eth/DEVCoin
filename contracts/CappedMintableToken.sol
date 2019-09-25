pragma solidity ^0.5.0;

import "./token/ERC20/ERC20Capped.sol";
import "./math/SafeMath.sol";

/**
 * @dev Implementation of `ERC20Capped`
 */
contract CappedMintableToken is ERC20Capped  {

    using SafeMath for uint256;

    string public name;
    uint8 public decimals;
    string public symbol;
    
    constructor
    (
        string  memory _tokenName,
        string memory _tokenSymbol,
        uint8   _decimalUnits,
        uint256 _cap
    )
    ERC20Capped(_cap)
    public  {
         name = _tokenName;
         symbol = _tokenSymbol;
         decimals = _decimalUnits;
    }
}