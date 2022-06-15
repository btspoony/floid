const REGEXP_IMPORT = /(\s*import\s*)([\w\d]+)(\s+from\s*)([\w\d"-.\\/]+)/g;

/**
 * Returns Cadence template code with replaced import addresses
 * @param code - Cadence template code.
 * @param addressMap - name/address map or function to use as lookup table
 * for addresses in import statements.
 * @param byName - lag to indicate whether we shall use names of the contracts.
 */
export const replaceImportAddresses = (
  code: string,
  addressMap: { [key: string]: string },
  byName = true
): string => {
  return code.replace(REGEXP_IMPORT, (match, imp, contract, _, address) => {
    const key = byName ? contract : address;
    const newAddress =
      addressMap instanceof Function ? addressMap(key) : addressMap[key];

    // If the address is not inside addressMap we shall not alter import statement
    const validAddress = newAddress || address;
    return `${imp}${contract} from ${validAddress}`;
  });
};
