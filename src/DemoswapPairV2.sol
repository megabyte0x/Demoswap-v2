// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.18;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {Math} from "./libraries/Math.sol";

interface IERC20 {
    function balanceOf(address) external returns (uint256);

    function transfer(address to, uint256 amount) external;
}

error DemoswapPairV2__InsufficientLiquidityMinted();

contract DemoswapPairV2 is ERC20, Math{

    string public constant NAME = "Demoswap LP Token";
    string public constant SYMBOL = "DSLP";
    uint8 public constant DECIMALS = 18;
    uint256 public constant MINIMUM_LIQUIDITY = 1000;

    address public immutable token0;
    address public immutable token1;

    uint112 private reserve0;
    uint112 private reserve1;

    event DemoswapPairV2__Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event DemoswapPairV2__Sync(uint112 reserve0, uint112 reserve1);
    
    constructor (address _token0, address _token1) ERC20 (NAME, SYMBOL, DECIMALS){
        token0 = _token0;
        token1 = _token1;
    }

    function mint() external {
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves();

        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));

        uint256 amount0 = balance0 - _reserve0;
        uint256 amount1 = balance1 - _reserve1;

        uint256 liquidity;

        if(totalSupply == 0) {
            liquidity = Math.sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY;
            _mint(address(0), MINIMUM_LIQUIDITY);
        }   else {
            liquidity = Math.min(
                (amount0 * totalSupply) / reserve0,
                (amount1 * totalSupply) / reserve1
            );
        }

        if(liquidity<=0) revert DemoswapPairV2__InsufficientLiquidityMinted();

        _mint(msg.sender, liquidity);
        
        _update(balance0, balance1);

        emit DemoswapPairV2__Mint(msg.sender, amount0, amount1);
    }

    function getReserves() public view 
        returns (
            uint112,
            uint112,
            uint32
        )
    {
        return (reserve0, reserve1, 0);
    }

    function _update(uint256 balance0, uint256 balance1) private {
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);

        emit DemoswapPairV2__Sync(reserve0, reserve1);
    }
}