// Copyright (C) 2020 Centrifuge

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity >=0.5.15 <0.6.0;

import "ds-test/test.sol";
import "./../deployer.sol";

import { TitleFab } from "./borrower/fabs/title.sol";
import { PileFab } from "./borrower/fabs/pile.sol";
import { ShelfFab} from "./borrower/fabs/shelf.sol";
import { NAVFeedFab } from "./borrower/fabs/navfeed.sol";
import { NFTFeedFab } from "./borrower/fabs/nftfeed.sol";
import { CollectorFab } from "./borrower/fabs/collector.sol";


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
