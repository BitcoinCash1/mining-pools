# Bitcoin Mining Pools

Mining pools definition used on: https://bchexplorer.cash/mining/pools

# Contributing

Contributions welcome! All changes must be applied in `pools-v2.json` file.

## Adding a new mining pool

Regardless of the choosen method, we recommend adding a appropriate slug to each
new mining pool you add to `pools-v2.json`. The slug will be used as a unique tag for
the mining pool, for example in the public facing URLs like: https://bchexplorer.cash/mining/pool/foundryusa (here `foundryusa` is the slug).

### Add a new mining pool by `coinbase_tags`

You can add a new mining pool by specifying the coinbase tag they're using in
the coinbase transaction.

To add a new pool, you must add a new JSON object in the `coinbase_tags` object.
Note that you can add multiple tags for the same mining pool, but you _must_ use
the exact same values for `name` and `link` in each new entry.

For example:

```json
"Foundry USA Pool" : {
  "name" : "Foundry USA",
  "link" : "https://foundrydigital.com/"
},
"Foundry USA Pool another tag" : {
  "name" : "Foundry USA",
  "link" : "https://foundrydigital.com/"
},
```

Each coinbase tag will be use as a regex to match blocks with their mining pool.
This is how we use it in mempool application. You can see the code [here](https://gitlab.melroy.org/bitcoincash/bitcoin-cash-explorer/-/blob/main/backend/src/api/pools-parser.ts?ref_type=heads#L148).

```ts
const regexes: string[] =
  typeof pools[i].regexes === "string"
    ? JSON.parse(pools[i].regexes)
    : pools[i].regexes;
for (let y = 0; y < regexes.length; ++y) {
  const regex = new RegExp(regexes[y], "i");
  const match = asciiScriptSig.match(regex);
  if (match !== null) {
    return pools[i];
  }
}
```

### Add a new mining pool by `payout_addresses`

You can add a new mining pool by specifying the receiving address they're using in
the coinbase transaction to receive the miner reward.

To add a new pool, you must add a new JSON object in the `payout_addresses` object.
Note that you can add multiple addresses for the same mining pool, but you _must_ use
the exact same values for `name` and `link` in each new entry.
For example:

```json
"1FFxkVijzvUPUeHgkFjBk2Qw8j3wQY2cDw" : {
    "name" : "Foundry USA",
    "link" : "https://foundrydigital.com/"
},
"12KKDt4Mj7N5UAkQMN7LtPZMayenXHa8KL" : {
    "name" : "Foundry USA",
    "link" : "https://foundrydigital.com/"
},
```

Each address will be use to match blocks with their mining pool by matching the
coinbase transaction output address.
This is how we use it in mempool application. You can see the code [here](https://gitlab.melroy.org/bitcoincash/bitcoin-cash-explorer/-/blob/main/backend/src/api/pools-parser.ts?ref_type=heads#L139).

```ts
const poolAddresses: string[] =
  typeof pools[i].addresses === "string"
    ? JSON.parse(pools[i].addresses)
    : pools[i].addresses;
for (let y = 0; y < poolAddresses.length; y++) {
  if (addresses.indexOf(poolAddresses[y]) !== -1) {
    return pools[i];
  }
}
```

## Change an existing mining pool metadata

You can also change an existing mining pool's name, link and slug. In order to
do so properly, you must update all existing entry in the `pools-v2.json` file.

For example, if you'd like to rename `Foundry USA` to `Foundry Pool`, you must replace
all occurences of the old string with the new one in `pools-v2.json` file, with no
exception, otherwise you'll end with two mining pools. The samme idea applies if
you want to change the link or the slug.

For example, to rename `Foundry USA` to `Foundry Pool` you'd need to update the
following (using today's `pools-v2.json` as reference):

```json
// Original
"Foundry USA Pool" : {
    "name" : "Foundry USA",
    "link" : "https://foundrydigital.com/"
},
  "/2cDw/" : {
    "name" : "Foundry USA",
    "link" : "https://foundrydigital.com/"
},
// Renamed
"Foundry USA Pool" : {
    "name" : "Foundry Pool",
    "link" : "https://foundrydigital.com/"
},
  "/2cDw/" : {
    "name" : "Foundry Pool",
    "link" : "https://foundrydigital.com/"
},
```

```json
// Original
"1FFxkVijzvUPUeHgkFjBk2Qw8j3wQY2cDw" : {
    "name" : "Foundry USA",
    "link" : "https://foundrydigital.com/"
},
"12KKDt4Mj7N5UAkQMN7LtPZMayenXHa8KL" : {
    "name" : "Foundry USA",
    "link" : "https://foundrydigital.com/"
},
// Renamed
"1FFxkVijzvUPUeHgkFjBk2Qw8j3wQY2cDw" : {
    "name" : "Foundry Pool",
    "link" : "https://foundrydigital.com/"
},
"12KKDt4Mj7N5UAkQMN7LtPZMayenXHa8KL" : {
    "name" : "Foundry Pool",
    "link" : "https://foundrydigital.com/"
},
```

```json
// Original
"Foundry USA": "foundryusa",
// Renamed - Be aware, this will also change the mining pool page link from
// bchexplorer.cash/mining/pool/foundryusa to bchexplorer.cash/mining/pool/foundrypool
"Foundry Pool": "foundrypool",
```

## Block re-indexing

When a mining pool's coinbase tag or addresses is updated in `pools-v2.jon`,
mempool can automatically re-index the appropriate blocks in order to re-assign
them to the correct mining pool.

"Appropriate" blocks here concern all blocks which are not yet assigned to a
mining pool (`unknown` pool), from block 130635 (first known mining pool block)
as well as all blocks from the update mining pool.
You can find the re-indexing logic [here](https://gitlab.melroy.org/bitcoincash/bitcoin-cash-explorer/-/blob/main/backend/src/api/pools-parser.ts?ref_type=heads#L197)

You can enable/disable this behavior using by setting the following backend
configuration variable:

```json
{
  "MEMPOOL": {
    "AUTOMATIC_POOLS_UPDATE": false
  }
}
```

If you set it to false, no re-indexing will happen automatically, but this also
means that you will need to delete blocks manually from your database. Upon
restarting your backend, missing indexed blocks are always be re-indexed using
the latest mining pool data.

## Mining pool definition

When the mempool backend starts, we automatically fetch the latest `pools-v2.json`
version from github. By default the url points to `https://gitlab.melroy.org/bitcoincash/mining-pools/-/raw/main/pools-v2.json` but you can configure it to points to another repo by setting
the following backend variables:

```json
{
  "MEMPOOL": {
    "POOLS_JSON_URL": "https://gitlab.melroy.org/bitcoincash/mining-pools/-/raw/main/pools-v2.json",
    "POOLS_JSON_TREE_URL": "https://gitlab.melroy.org/api/v4/projects/199/repository/tree"
  }
}
```
