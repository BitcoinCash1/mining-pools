# Bitcoin Mining Pools

Mining pools definition used on: https://bchexplorer.cash/mining/pools

# Contributing

Contributions welcome! All changes must be applied in `pools-v2.json` file.

## Adding a new mining pool

Adding a new mining pool is done by extending the `pools-v2.json` file. It is important to give it an unique ID (`id` key).

And run: `./dupes.sh` script to validate that there are *no* duplicates.

_Note:_ The pool name will automatically becomes the slug (eg. https://bchexplorer.cash/mining/pool/viabtc (here `viabtc` is the slug).

### New mining pool (detailed explanation)

You can add a new mining pool by specifying the coinbase tag they're using in
the coinbase transaction.

To add a new pool, you must add a new **JSON object** (see example below) at the bottom of the existing `pools-v2.json` **JSON array**.

Note that you can add multiple `tags` (type array) for the same mining pool. Same for `addresses` (optional).
For example:

```json
{
  "id": 6,
  "name": "BTC.com",
  "addresses": [
    "bitcoincash:qpv5y82t8z7n6w80fpm64afah7ntptxue59h5cdsn2"
  ],
  "tags": ["/BTC.COM/", "/BTC.com/", "btccom"],
  "link": "https://pool.btc.com"
},
```

---

Each coinbase tag will be use as a regex to match blocks with their mining pool.
This is how we use it in BCH Explorer application. You can see the code [here](https://gitlab.melroy.org/bitcoincash/bitcoin-cash-explorer/-/blob/main/backend/src/api/pools-parser.ts?ref_type=heads#L148).

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

Each address will be use to match blocks with their mining pool by matching the
coinbase transaction output address.
This is how we use it in BCH Explorer application. You can see the code [here](https://gitlab.melroy.org/bitcoincash/bitcoin-cash-explorer/-/blob/main/backend/src/api/pools-parser.ts?ref_type=heads#L139).

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

## Change an existing mining pool

For example, to rename `BTC.com` to `BTC` you'd need to update the 
following (using today's `pools-v2.json` as reference):

```json
// Original
{
  "id": 6,
  "name": "BTC.com",
  "addresses": [
    "bitcoincash:qpv5y82t8z7n6w80fpm64afah7ntptxue59h5cdsn2"
  ],
  "tags": ["/BTC.COM/", "/BTC.com/", "btccom"],
  "link": "https://pool.btc.com"
},
// Renamed
{
  "id": 6,
  "name": "BTC",
  "addresses": [
    "bitcoincash:qpv5y82t8z7n6w80fpm64afah7ntptxue59h5cdsn2"
  ],
  "tags": ["/BTC.COM/", "/BTC.com/", "btccom"],
  "link": "https://pool.btc.com"
},
```

## Block re-indexing

When a mining pool's coinbase tag or addresses is updated in `pools-v2.jon`,
BCH Explorer can automatically re-index the appropriate blocks in order to re-assign
them to the correct mining pool.

"Appropriate" blocks here concern all blocks which are not yet assigned to a
mining pool (`unknown` pool), from block 130635 (first known mining pool block)
as well as all blocks from the update mining pool.
You can find the re-indexing logic [here](https://gitlab.melroy.org/bitcoincash/bitcoin-cash-explorer/-/blob/main/backend/src/api/pools-parser.ts?ref_type=heads#L197)

You can enable/disable this behavior using by setting the following backend
configuration variable:

```json
{
  "EXPLORER": {
    "AUTOMATIC_POOLS_UPDATE": false
  }
}
```

If you set it to false, no re-indexing will happen automatically, but this also
means that you will need to delete blocks manually from your database. Upon
restarting your backend, missing indexed blocks are always be re-indexed using
the latest mining pool data.

## Mining pool definition

When the BCH Explorer backend (re)starts, we automatically fetch the latest `pools-v2.json`
version from github. By default the url points to `https://gitlab.melroy.org/bitcoincash/mining-pools/-/raw/main/pools-v2.json` but you can configure it to points to another repo by setting
the following backend variables:

```json
{
  "EXPLORER": {
    "POOLS_JSON_URL": "https://gitlab.melroy.org/bitcoincash/mining-pools/-/raw/main/pools-v2.json",
    "POOLS_JSON_TREE_URL": "https://gitlab.melroy.org/api/v4/projects/199/repository/tree"
  }
}
```
