// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.6.12;

import "ds-test/test.sol";
import "./../deployer.sol";
import "tinlake/borrower/fabs/pile.sol";

contract FabDeployerTest is DSTest {
    MainDeployer deployer;

    function setUp() public {
        deployer = new MainDeployer();
    }

    function testFabDeploy() public {
        bytes memory pileFabBytes = type(PileFab).creationCode;
        bytes32 pileFabHash = keccak256(pileFabBytes);
        // fab should not exist
        assertEq(deployer.getAddress(pileFabHash, "pileFab"), address(0));

        deployer.deploy(pileFabBytes, "pileFab");

        address pileFab_ = deployer.getAddress(pileFabHash, "pileFab");
        assertTrue(pileFab_ != address(0));

        PileFab pileFab = PileFab(pileFab_);
        address pile_ = pileFab.newPile();

        Pile pile = Pile(pile_);
        assertEq(pile.wards(address(this)), 1);
    }
}
