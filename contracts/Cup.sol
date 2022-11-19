//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Betting is Ownable {
	struct Team {
		string name;
		uint256 totalBetAmount;
		uint256 totalBetCount;
	}
	struct Bet {
		string name;
		address addy;
		Team teamBet;
		uint256 amount;
	}
	IERC20 betToken;

	Bet[] public bets;
	Team[] public teams;

	uint256 public totalBetMoney;
	uint256 private winnerId;
	bool isEnded;
	address conOwner;

	mapping(address => uint256) numBetsAddress;

	event NewBet(address addy, uint256 amount, Team teamBet);

	constructor(
		IERC20 _betToken,
		string memory _team1,
		string memory _team2
	) {
		betToken = _betToken;
		conOwner = msg.sender;
		teams.push(Team(_team1, 0, 0));
		teams.push(Team(_team2, 0, 0));
	}

	function createBet(
		string memory _name,
		uint256 _teamId,
		uint256 _betAmount
	) external {
		require(msg.sender != conOwner, "owner can't make a bet");
		require(isEnded == false, "Game already ended");
		require(
			numBetsAddress[msg.sender] == 0,
			"you have already placed a bet"
		);
		require(_betAmount > 0.01 ether, "bet more");

		bets.push(Bet(_name, msg.sender, teams[_teamId], _betAmount));

		if (_teamId == 0) {
			teams[0].totalBetAmount += _betAmount;
			teams[0].totalBetCount++;
		}
		if (_teamId == 1) {
			teams[1].totalBetAmount += _betAmount;
			teams[1].totalBetCount++;
		}

		numBetsAddress[msg.sender]++;

		// (bool sent, bytes memory data) = conOwner.call{ value: _betAmount }("");
		// require(sent, "Failed to send Ether");

		betToken.transferFrom(msg.sender, address(this), _betAmount);

		totalBetMoney += _betAmount;

		emit NewBet(msg.sender, _betAmount, teams[_teamId]);
	}

	function _distribute(
		uint256 _betId,
		uint256 _winnerId,
		uint256 _loserId
	) private {
		//suppose 1 is winner
		Bet memory winningBet = bets[_betId];
		uint256 div = winningBet.amount +
			((winningBet.amount * getTotalBetAmount(_loserId)) /
				getTotalBetAmount(_winnerId) /
				2);

		betToken.transfer(winningBet.addy, div);
	}

	/////////////////////
	// Admin function  //
	/////////////////////

	function teamWinDistribution(uint256 _teamId) public onlyOwner {
		winnerId = _teamId;

		if (_teamId == 0) {
			for (uint256 i = 0; i < bets.length; i++) {
				if (
					keccak256(abi.encodePacked((bets[i].teamBet.name))) ==
					keccak256(abi.encodePacked(teams[0].name))
				) {
					_distribute(i, 0, 1);
				}
			}
		} else {
			for (uint256 i = 0; i < bets.length; i++) {
				if (
					keccak256(abi.encodePacked((bets[i].teamBet.name))) ==
					keccak256(abi.encodePacked(teams[1].name))
				) {
					_distribute(i, 1, 0);
				}
			}
		}

		totalBetMoney = 0;
		teams[0].totalBetAmount = 0;
		teams[1].totalBetAmount = 0;

		for (uint256 i = 0; i < bets.length; i++) {
			numBetsAddress[bets[i].addy] = 0;
		}
		isEnded = true;
	}

	function createTeam(string memory _name) external onlyOwner {
		teams.push(Team(_name, 0, 0));
	}

	function withdraw() external onlyOwner {
		require(isEnded == true, "No withdraw before ends");
		uint256 residualBalance = betToken.balanceOf(address(this));
		betToken.transfer(msg.sender, residualBalance);
	}

	/////////////////////
	/// View function  //
	/////////////////////

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

	function getGameResult() public view returns (string memory) {
		require(isEnded == true, "Game not ended yet");
		return teams[winnerId].name;
	}

	function getWinnerCount() public view returns (uint256) {
		require(isEnded == true, "Game not ended yet");
		return teams[winnerId].totalBetCount;
	}
}
