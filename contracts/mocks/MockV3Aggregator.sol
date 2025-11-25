// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract MockV3Aggregator is AggregatorV3Interface {
    uint8 public decimals;
    int256 public latestAnswer;
    uint80 public latestRound;
    uint256 public version = 1;

    constructor(uint8 _decimals, int256 _initialAnswer) {
        decimals = _decimals;
        latestAnswer = _initialAnswer;
        latestRound = 1;
    }

    function getRoundData(uint80 _roundId)
        external
        view
        override
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return (_roundId, latestAnswer, block.timestamp, block.timestamp, _roundId);
    }

    function latestRoundData()
        external
        view
        override
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return (latestRound, latestAnswer, block.timestamp, block.timestamp, latestRound);
    }

    function description() external pure override returns (string memory) {
        return "MockV3Aggregator";
    }
}







