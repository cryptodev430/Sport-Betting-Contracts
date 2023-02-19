//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPancakeRouter01 {
	function factory() external pure returns (address);

	function WETH() external pure returns (address);

	function addLiquidity(
		address tokenA,
		address tokenB,
		uint256 amountADesired,
		uint256 amountBDesired,
		uint256 amountAMin,
		uint256 amountBMin,
		address to,
		uint256 deadline
	)
		external
		returns (
			uint256 amountA,
			uint256 amountB,
			uint256 liquidity
		);

	function addLiquidityETH(
		address token,
		uint256 amountTokenDesired,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline
	)
		external
		payable
		returns (
			uint256 amountToken,
			uint256 amountETH,
			uint256 liquidity
		);

	function removeLiquidity(
		address tokenA,
		address tokenB,
		uint256 liquidity,
		uint256 amountAMin,
		uint256 amountBMin,
		address to,
		uint256 deadline
	) external returns (uint256 amountA, uint256 amountB);

	function removeLiquidityETH(
		address token,
		uint256 liquidity,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline
	) external returns (uint256 amountToken, uint256 amountETH);

	function removeLiquidityWithPermit(
		address tokenA,
		address tokenB,
		uint256 liquidity,
		uint256 amountAMin,
		uint256 amountBMin,
		address to,
		uint256 deadline,
		bool approveMax,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external returns (uint256 amountA, uint256 amountB);

	function removeLiquidityETHWithPermit(
		address token,
		uint256 liquidity,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline,
		bool approveMax,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external returns (uint256 amountToken, uint256 amountETH);

	function swapExactTokensForTokens(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);

	function swapTokensForExactTokens(
		uint256 amountOut,
		uint256 amountInMax,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);

	function swapExactETHForTokens(
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external payable returns (uint256[] memory amounts);

	function swapTokensForExactETH(
		uint256 amountOut,
		uint256 amountInMax,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);

	function swapExactTokensForETH(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns (uint256[] memory amounts);

	function swapETHForExactTokens(
		uint256 amountOut,
		address[] calldata path,
		address to,
		uint256 deadline
	) external payable returns (uint256[] memory amounts);

	function quote(
		uint256 amountA,
		uint256 reserveA,
		uint256 reserveB
	) external pure returns (uint256 amountB);

	function getAmountOut(
		uint256 amountIn,
		uint256 reserveIn,
		uint256 reserveOut
	) external pure returns (uint256 amountOut);

	function getAmountIn(
		uint256 amountOut,
		uint256 reserveIn,
		uint256 reserveOut
	) external pure returns (uint256 amountIn);

	function getAmountsOut(uint256 amountIn, address[] calldata path)
		external
		view
		returns (uint256[] memory amounts);

	function getAmountsIn(uint256 amountOut, address[] calldata path)
		external
		view
		returns (uint256[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
	function removeLiquidityETHSupportingFeeOnTransferTokens(
		address token,
		uint256 liquidity,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline
	) external returns (uint256 amountETH);

	function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
		address token,
		uint256 liquidity,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline,
		bool approveMax,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external returns (uint256 amountETH);

	function swapExactTokensForTokensSupportingFeeOnTransferTokens(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external;

	function swapExactETHForTokensSupportingFeeOnTransferTokens(
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external payable;

	function swapExactTokensForETHSupportingFeeOnTransferTokens(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external;
}

contract Betting is Ownable {
	struct Team {
		string name;
		uint256 totalBetAmount;
		uint256 totalBetCount;
	}
	struct Bet {
		address addy;
		Team teamBet;
		uint256 amount;
	}
	// IERC20 betToken;

	Bet[] public bets;
	Team[] public teams;

	uint256 public totalBetMoney;
	uint256 private winnerId;
	uint256 public gameStatus; //0: upcoming   1: live    2: end

	uint256 public betMin = 0.05 ether;
	uint256 public betMax = 1 ether;

	IERC20 public QBToken;
	address conOwner;
	address QBOwner;
	address WBNBAddress;

	mapping(address => uint256) numBetsAddress;

	address public PANCAKESWAP_ROUTER;

	event NewBet(address addy, uint256 amount, Team teamBet);

	constructor(
		string memory _team1,
		string memory _team2,
		IERC20 _token,
		address _router
	) payable {
		QBToken = _token;
		PANCAKESWAP_ROUTER = _router;
		QBOwner = msg.sender;
		conOwner = payable(msg.sender);
		teams.push(Team(_team1, 0, 0));
		teams.push(Team(_team2, 0, 0));
		teams.push(Team("Draw", 0, 0));

		WBNBAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
	}

	function createBet(uint256 _teamId) external payable {
		require(msg.sender != conOwner, "owner can't make a bet");
		require(gameStatus == 0, "Betting ended");
		require(
			numBetsAddress[msg.sender] == 0,
			"you have already placed a bet"
		);
		uint256 _betAmount = msg.value;
		require(_betAmount >= betMin, "bet more");

		require(_betAmount <= betMax, "bet less");

		bets.push(Bet(msg.sender, teams[_teamId], _betAmount));
		teams[_teamId].totalBetAmount += _betAmount;
		teams[_teamId].totalBetCount++;

		numBetsAddress[msg.sender]++;

		// (bool sent, bytes memory data) = conOwner.call{ value: _betAmount }(
		// 	""
		// );
		// require(sent, "Failed to deposit Bnb");

		// betToken.transferFrom(msg.sender, address(this), _betAmount);

		totalBetMoney += _betAmount;

		emit NewBet(msg.sender, _betAmount, teams[_teamId]);
	}

	function _distribute(uint256 _betId, uint256 _winnerId) private {
		//suppose 1 is winner
		Bet memory winningBet = bets[_betId];
		uint256 available = totalBetMoney - getTotalBetAmount(_winnerId);
		uint256 div = winningBet.amount +
			((winningBet.amount * available) / getTotalBetAmount(_winnerId) / 2);

		address payable receiver = payable(winningBet.addy);

		receiver.transfer(div);

		// betToken.transfer(winningBet.addy, div);
	}

	/////////////////////
	// Admin function  //
	/////////////////////

	function teamWinDistribution(uint256 _teamId) public onlyOwner {
		winnerId = _teamId;

		for (uint256 i = 0; i < bets.length; i++) {
			if (
				keccak256(abi.encodePacked((bets[i].teamBet.name))) ==
				keccak256(abi.encodePacked(teams[_teamId].name))
			) {
				_distribute(i, _teamId);
			}
		}

		for (uint256 i = 0; i < bets.length; i++) {
			numBetsAddress[bets[i].addy] = 0;
		}
		gameStatus = 2;
	}

	function setMinBetAmount(uint256 _value) external onlyOwner {
		betMin = _value;
	}

	function setMaxBetAmount(uint256 _value) external onlyOwner {
		betMax = _value;
	}

	function setRouterAddress(address _router) external onlyOwner {
		PANCAKESWAP_ROUTER = _router;
	}

	function setGameStatus(uint256 _status) external onlyOwner {
		require(gameStatus < 2, "Game already ended");
		gameStatus = _status;
	}

	function withdraw() external onlyOwner {
		require(gameStatus == 2, "No withdraw before ends");
		uint256 residualBalance = totalBetMoney - getTotalBetAmount(winnerId);
		address payable to = payable(msg.sender);

		to.transfer(residualBalance / 2);
	}

	function addLiquidity() external payable onlyOwner {
		require(gameStatus == 2, "No withdraw before ends");

		uint256 residualBalance = totalBetMoney - getTotalBetAmount(winnerId);
		address tokenAddress = address(QBToken);

		address[] memory path;
		path = new address[](2);
		path[0] = WBNBAddress;
		path[1] = tokenAddress;
		uint256[] memory out;
		out = IPancakeRouter02(PANCAKESWAP_ROUTER).getAmountsOut(
			residualBalance / 2,
			path
		);

		// _addLiquidity(address(QBToken), residualBalance / 2);

		IERC20(tokenAddress).approve(PANCAKESWAP_ROUTER, out[1]);

		IPancakeRouter02(PANCAKESWAP_ROUTER).addLiquidityETH{
			value: residualBalance / 2
		}(tokenAddress, out[1], 0, 0, QBOwner, block.timestamp);

		// betToken.transfer(msg.sender, residualBalance);
	}

	/////////////////////
	/// View function  //
	/////////////////////

	function getBetStatus(address _user)
		public
		view
		returns (string memory teamName, uint256 result)
	{
		for (uint256 i = 0; i < bets.length; i++) {
			if (bets[i].addy == _user) {
				teamName = bets[i].teamBet.name;
			}
		}
		if (gameStatus < 2) {
			result = 3;
		} else {
			for (uint256 i = 0; i < 3; i++) {
				if (
					keccak256(abi.encodePacked(teamName)) ==
					keccak256(abi.encodePacked(teams[i].name))
				) {
					result = i;
				}
			}
		}
	}

	function getTotalBetAmount(uint256 _teamId)
		public
		view
		returns (uint256)
	{
		return teams[_teamId].totalBetAmount;
	}

	function getTotalBetCounts(uint256 _teamId)
		public
		view
		returns (uint256)
	{
		return teams[_teamId].totalBetCount;
	}

	function getGameResult() public view returns (string memory result) {
		require(gameStatus == 2, "Game not ended yet");

		result = teams[winnerId].name;
	}

	function getWinnerCount() public view returns (uint256) {
		require(gameStatus == 2, "Game not ended yet");

		return teams[winnerId].totalBetCount;
	}
}
