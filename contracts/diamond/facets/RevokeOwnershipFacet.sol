pragma solidity ^0.8.11;
import "@moonstream/contracts/moonstream/LibERC20.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";
import {IDiamondCut} from "../interfaces/IDiamondCut.sol";
import {OwnershipFacet} from "./OwnershipFacet.sol";

contract RevokeOwnershipFacet {
    function revokeOwnership() external {
        LibERC20.enforceIsController();
        LibDiamond.enforceIsContractOwner();

        // Remove diamondCut function
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
        bytes4[] memory functionSelectors = new bytes4[](3);
        functionSelectors[0] = IDiamondCut.diamondCut.selector;
        functionSelectors[1] = OwnershipFacet.transferOwnership.selector;
        functionSelectors[2] = RevokeOwnershipFacet.revokeOwnership.selector;
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: address(0),
            action: IDiamondCut.FacetCutAction.Remove,
            functionSelectors: functionSelectors
        });
        LibDiamond.diamondCut(cut, address(0), "");

        //Delegating controller to 0 address
        LibERC20.setController(address(0));
        //Delegating owner to 0 address
        LibDiamond.setContractOwner(address(0));
    }
}
