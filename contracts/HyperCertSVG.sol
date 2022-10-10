// SPDX-License-Identifier: MIT
// Ref: https://github.com/solv-finance/solv-v2-ivo/blob/main/vouchers/bond-voucher/contracts/BondVoucherDescriptor.sol

pragma solidity ^0.8.14;

import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "./lib/DateTime.sol";
import "./lib/strings.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract HyperCertSVG is Initializable, AccessControlUpgradeable, UUPSUpgradeable {
    using StringsUpgradeable for uint256;
    using strings for *;

    /// @notice User role required in order to upgrade the contract
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    /// @notice Current version of the contract
    uint16 internal _version;

    /// @dev id => background
    mapping(uint256 => string) public backgrounds;

    /// @dev id => colors
    mapping(uint256 => SVGColors) public colors;

    uint256 public backgroundCounter;
    uint256 public colorsCounter;

    struct SVGParams {
        string name;
        string[] scopesOfImpact;
        uint64[2] workTimeframe;
        uint64[2] impactTimeframe;
        uint256 units;
        uint256 totalUnits;
    }

    /// 1: Divider, graphic, title, units
    /// 2: Header/footer, scope labels
    /// 3: Backgrounds
    struct SVGColors {
        string primary;
        string labels;
        string background;
    }

    event BackgroundAdded(uint256 id);
    event ColorsAdded(uint256 id, SVGColors colors);

    /*******************
     * DEPLOY
     ******************/

    /// @notice Contract constructor logic
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Contract initialization logic
    function initialize() public initializer {
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);

        backgroundCounter = 0;
        colorsCounter = 0;
    }

    function addBackground(string memory svgString) external returns (uint256 id) {
        id = backgroundCounter;
        backgrounds[id] = svgString;
        emit BackgroundAdded(id);
        backgroundCounter += 1;
    }

    function addColors(string[3] memory _colors) external returns (uint256 id) {
        id = colorsCounter;
        SVGColors memory svgColors = SVGColors({ primary: _colors[0], labels: _colors[1], background: _colors[2] });
        colors[id] = svgColors;
        emit ColorsAdded(id, svgColors);
        colorsCounter += 1;
    }

    function generateSvgHyperCert(
        string memory name,
        string[] memory scopesOfImpact,
        uint64[2] memory workTimeframe,
        uint64[2] memory impactTimeframe,
        uint256 totalUnits
    ) external view virtual returns (string memory) {
        SVGParams memory svgParams;
        svgParams.name = name;
        svgParams.scopesOfImpact = scopesOfImpact;
        svgParams.workTimeframe = workTimeframe;
        svgParams.impactTimeframe = impactTimeframe;
        svgParams.totalUnits = totalUnits;
        return _generateHyperCert(svgParams);
    }

    function generateSvgFraction(
        string memory name,
        string[] memory scopesOfImpact,
        uint64[2] memory workTimeframe,
        uint64[2] memory impactTimeframe,
        uint256 units,
        uint256 totalUnits
    ) external view virtual returns (string memory) {
        SVGParams memory svgParams;
        svgParams.name = name;
        svgParams.scopesOfImpact = scopesOfImpact;
        svgParams.workTimeframe = workTimeframe;
        svgParams.impactTimeframe = impactTimeframe;
        svgParams.units = units;
        svgParams.totalUnits = totalUnits;
        return _generateHyperCertFraction(svgParams);
    }

    function _generateHyperCert(SVGParams memory params) internal view virtual returns (string memory) {
        SVGColors memory colors_ = _generateColors(params.scopesOfImpact[0]);
        return
            string(
                abi.encodePacked(
                    '<svg width="550" height="850" viewBox="0 0 550 850" '
                    'xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">',
                    _generateBackground(params.scopesOfImpact[0], colors_.background),
                    _generateHeader(params, colors_.labels, colors_.background),
                    _generateName(params, colors_.primary),
                    _generateScopeOfImpact(params, colors_.labels),
                    _generateFooter(params, colors_.labels),
                    "</svg>"
                )
            );
    }

    /// 1: Divider, graphic, title, units
    /// 2: Header/footer, scope labels
    /// 3: Backgrounds

    function _generateHyperCertFraction(SVGParams memory params) internal view virtual returns (string memory) {
        SVGColors memory colors_ = _generateColors(params.scopesOfImpact[0]);

        return
            string(
                abi.encodePacked(
                    '<svg width="550" height="850" viewBox="0 0 550 850" '
                    'xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">',
                    _generateBackground(params.scopesOfImpact[0], colors_.background),
                    _generateHeader(params, colors_.labels, colors_.background),
                    _generateName(params, colors_.primary),
                    _generateScopeOfImpact(params, colors_.labels),
                    _generateFraction(params, colors_.primary),
                    _generateFooter(params, colors_.labels),
                    "</svg>"
                )
            );
    }

    function _generateBackground(string memory primaryScopeOfImpact, string memory lineColor)
        internal
        view
        returns (string memory background)
    {
        string memory backgroundPattern = backgrounds[_getBackgroundIndex(primaryScopeOfImpact)];
        if (bytes(background).length == 0) {
            backgroundPattern = backgrounds[0];
        }

        return
            string.concat(
                '<rect id="background-color-2" x=".5" y="0" width="550" height="850" rx="32" ry="32"/>',
                '<g id="graphic-color"><path id="graphic-color-2" d="',
                backgroundPattern,
                '" style="fill: none; stroke: "',
                lineColor,
                '"; stroke-miterlimit: 10; stroke-width: 2px;"/></g>'
            );
    }

    function _generateColors(string memory primaryScopeOfImpact) internal view returns (SVGColors memory _colors) {
        if (colorsCounter == 0) {
            return _colors = SVGColors({ primary: "yellow", labels: "green", background: "purple" });
        }
        _colors = colors[_getColorIndex(primaryScopeOfImpact)];
        if (bytes(_colors.primary).length == 0) {
            _colors = colors[0];
        }
    }

    function _getBackgroundIndex(string memory primaryScopeOfImpact) internal view returns (uint256 index) {
        index = uint256(stringToBytes32(primaryScopeOfImpact)) % 10;
    }

    function _getColorIndex(string memory primaryScopeOfImpact) internal view returns (uint256 index) {
        index = uint256(stringToBytes32(primaryScopeOfImpact)) % colorsCounter;
    }

    function _generateHeader(
        SVGParams memory params,
        string memory fontColor,
        string memory lineColor
    ) internal pure virtual returns (string memory) {
        (uint256 yearFrom, uint256 monthFrom, uint256 dayFrom) = DateTime.timestampToDate(params.workTimeframe[0]);
        (uint256 yearTo, uint256 monthTo, uint256 dayTo) = DateTime.timestampToDate(params.workTimeframe[1]);

        return
            string(
                abi.encodePacked(
                    abi.encodePacked(
                        '<path id="foreground-color-2" '
                        'd="M435,777.83H115v-50H435v50Zm0-532.83H115v360H435V245Zm0-122.83H115v-50H435v50Z"/>'
                    ),
                    abi.encodePacked(
                        string.concat(
                            '<g id="divider-color" text-rendering="optimizeSpeed" font-size="10" fill="',
                            fontColor,
                            '">'
                        ),
                        '<path id="divider-color-2" d="M156.35,514.59h237.31" ',
                        string.concat(
                            'style="fill: none; stroke: "',
                            lineColor,
                            '"; stroke-miterlimit: 10; stroke-width: 2px;"/>'
                        ),
                        '<text id="work-period-color" transform="translate(134.75 102.06)" '
                        'style="font-family: Helvetica; font-size: 15px;">',
                        '<tspan x="0" y="0" style="letter-spacing: -.05em;">Work Period: ',
                        abi.encodePacked(yearFrom.toString(), "-", monthFrom.toString(), "-", dayFrom.toString()),
                        " > ",
                        abi.encodePacked(yearTo.toString(), "-", monthTo.toString(), "-", dayTo.toString()),
                        "</tspan></text></g>"
                    )
                )
            );
    }

    //TODO ugly string manipulation
    function _generateName(SVGParams memory params, string memory fontColor)
        internal
        pure
        virtual
        returns (string memory)
    {
        string memory renderedText = string.concat('<tspan x="0" y="0">', params.name, "</tspan>");
        uint256 inputLength = params.name.toSlice().len();
        if (inputLength > 13) {
            strings.slice memory ogSlice = params.name.toSlice();
            strings.slice memory delim = " ".toSlice();

            uint256 currentLine = 0;
            uint256 lineEntry = 0;
            uint256 lineLength = 0;
            strings.slice[] memory line = new strings.slice[](6);
            string[] memory allLines = new string[](3);

            while (currentLine < 3) {
                strings.slice memory part = ogSlice.split(delim);

                if (part.empty()) {
                    line[lineEntry] = ogSlice;
                    allLines[currentLine] = " ".toSlice().join(line);
                    break;
                }

                if (lineLength + part.len() > 10) {
                    if (currentLine == 2) line[lineEntry] = "...".toSlice();
                    allLines[currentLine] = " ".toSlice().join(line);

                    currentLine += 1;

                    line = new strings.slice[](6);
                    line[0] = part;
                    lineLength = part.len();
                    lineEntry = 1;
                } else {
                    lineLength += part.len();
                    line[lineEntry] = part;
                    lineEntry += 1;
                }
            }

            renderedText = string(
                abi.encodePacked(
                    abi.encodePacked('<tspan x="0" y="0">', allLines[0], "</tspan>"),
                    abi.encodePacked('<tspan x="0" y="36">', allLines[1], "</tspan>"),
                    abi.encodePacked('<tspan x="0" y="72">', allLines[2], "</tspan>")
                )
            );
        }

        return
            string(
                abi.encodePacked(
                    '<g id="name-color" text-rendering="optimizeSpeed" font-size="30">',
                    abi.encodePacked(
                        '<text id="name-color-2" transform="translate(156.35 300)" ',
                        string.concat('style="fill: "', fontColor, '"; font-family: Monaco;">'),
                        renderedText,
                        "</text>"
                    ),
                    "</g>"
                )
            );
    }

    function stringToBytes32(string memory source) internal pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        // solhint-disable-next-line no-inline-assembly
        assembly {
            result := mload(add(source, 32))
        }
    }

    function bytes32ToString(bytes32 _bytes32) internal pure returns (string memory) {
        uint8 i = 0;
        while (i < 27 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 27 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        string memory parsedString = string(bytesArray);
        if (_bytes32[28] != 0) {
            parsedString = string.concat(parsedString, "...");
        }
        return parsedString;
    }

    function _generateScopeOfImpact(SVGParams memory params, string memory fontColor)
        internal
        pure
        virtual
        returns (string memory)
    {
        string memory renderedText = "";
        uint256 inputLength = params.scopesOfImpact.length;
        if (inputLength > 3) inputLength = 3;
        for (uint256 i = 0; i < inputLength; i++) {
            bytes32 stringShort = stringToBytes32(params.scopesOfImpact[i]);
            renderedText = string.concat(
                renderedText,
                '<tspan x="0" y="',
                uint256(20 * i).toString(),
                '">',
                bytes32ToString(stringShort),
                "</tspan>"
            );
        }

        return
            string(
                abi.encodePacked(
                    string.concat(
                        '<g id="description-color" text-rendering="optimizeSpeed" font-size="15" fill="',
                        fontColor,
                        '">'
                    ),
                    '<text transform="translate(155 460)" style="font-family: Helvetica; font-size: 15px;"',
                    renderedText,
                    '"></text></g>'
                )
            );
    }

    function _generateFraction(SVGParams memory params, string memory fontColor)
        internal
        view
        virtual
        returns (string memory)
    {
        uint256 percent = getPercent(params.units, params.totalUnits);
        return
            string(
                abi.encodePacked(
                    '<g id="fraction-color" text-rendering="optimizeSpeed" font-size="30">',
                    '<text id="fraction-color-2" transform="translate(156.35 568.03)" ',
                    string.concat('style="fill: "', fontColor, '"; font-family: Monaco">'),
                    string.concat('<tspan x="0" y="0">', string(uint2decimal(percent, 2)), " %</tspan></text></g>")
                )
            );
    }

    function _generateTotalUnits(SVGParams memory params, string memory fontColor)
        internal
        pure
        virtual
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    '<g id="total-units-color" text-rendering="optimizeSpeed" font-size="30">',
                    '<text id="total-units-color" transform="translate(156.35 568.03)" ',
                    string.concat('style="fill: "', fontColor, '"; font-family: Monaco">'),
                    string.concat('<tspan x="0" y="0">', params.totalUnits.toString(), "</tspan></text></g>")
                )
            );
    }

    function _generateFooter(SVGParams memory params, string memory fontColor)
        internal
        pure
        virtual
        returns (string memory)
    {
        (uint256 yearFrom, uint256 monthFrom, uint256 dayFrom) = DateTime.timestampToDate(params.impactTimeframe[0]);
        (uint256 yearTo, uint256 monthTo, uint256 dayTo) = DateTime.timestampToDate(params.impactTimeframe[1]);
        return
            string(
                abi.encodePacked(
                    string.concat(
                        '<g id="impact-period-color" text-rendering="optimizeSpeed" font-size="10" fill="',
                        fontColor,
                        '">'
                    ),
                    '<text id="impact-period-color-2" transform="translate(134.75 758)" '
                    'style="font-family: Helvetica; font-size: 15px;">',
                    '<tspan x="0" y="0" style="letter-spacing: -.05em;">Impact Period: ',
                    abi.encodePacked(yearFrom.toString(), "-", monthFrom.toString(), "-", dayFrom.toString()),
                    " > ",
                    abi.encodePacked(yearTo.toString(), "-", monthTo.toString(), "-", dayTo.toString()),
                    "</tspan></text></g>"
                )
            );
    }

    function getPercent(uint256 part, uint256 whole) public pure returns (uint256 percent) {
        uint256 numerator = part * 100000;
        require(numerator > part, "Overflow"); // Should use SafeMath throughout if this was a real implementation.
        uint256 temp = numerator / whole + 5; // proper rounding up
        return temp / 10;
    }

    function uint2decimal(uint256 self, uint8 decimals) internal view returns (bytes memory) {
        uint256 base = 10**decimals;
        string memory round = (self / base).toString();
        string memory fraction = (self % base).toString();
        uint256 fractionLength = bytes(fraction).length;

        bytes memory fullStr = abi.encodePacked(round, ".");
        if (fractionLength < decimals) {
            for (uint8 i = 0; i < decimals - fractionLength; i++) {
                fullStr = abi.encodePacked(fullStr, "0");
            }
        }

        return abi.encodePacked(fullStr, fraction);
    }

    /*******************
     * ADMIN
     ******************/
    /// @notice gets the current version of the contract
    function version() public view virtual returns (uint256) {
        return _version;
    }

    /// @notice Update the contract version number
    /// @notice Only allowed for member of UPGRADER_ROLE
    function updateVersion() external onlyRole(UPGRADER_ROLE) {
        _version += 1;
    }

    /// @notice Returns a flag indicating if the contract supports the specified interface
    /// @param interfaceId Id of the interface
    /// @return true, if the interface is supported
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /// @notice upgrade authorization logic
    /// @dev adds onlyRole(UPGRADER_ROLE) requirement
    function _authorizeUpgrade(
        address /*newImplementation*/
    )
        internal
        view
        override
        onlyRole(UPGRADER_ROLE) // solhint-disable-next-line no-empty-blocks
    {
        //empty block
    }
}
