pragma solidity ^0.5.6;

import "ds-test/test.sol";

import "./TinlakeDeploy.sol";

contract TinlakeDeployTest is DSTest {
    TinlakeDeploy deploy;

    function setUp() public {
        deploy = new TinlakeDeploy();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
