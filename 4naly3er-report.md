# Report


## Gas Optimizations


| |Issue|Instances|
|-|:-|:-:|
| [GAS-1](#GAS-1) | For Operations that will not overflow, you could use unchecked | 214 |
| [GAS-2](#GAS-2) | `++i` costs less gas than `i++`, especially when it's used in `for`-loops (`--i`/`i--` too) | 1 |
| [GAS-3](#GAS-3) | Use shift Right/Left instead of division/multiplication if possible | 2 |
| [GAS-4](#GAS-4) | Use != 0 instead of > 0 for unsigned integer comparison | 2 |
### <a name="GAS-1"></a>[GAS-1] For Operations that will not overflow, you could use unchecked

*Instances (214)*:
```solidity
File: Float128.sol

4: import {Uint512} from "../lib/Uint512.sol";

5: import {packedFloat} from "./Types.sol";

52:     int constant MAXIMUM_EXPONENT = -18; // guarantees all results will have at least 18 decimals in the M size. Autoscales to L if necessary

167:                 r := or(r, MANTISSA_SIGN_MASK) // assign the negative sign

168:                 addition := sub(0, addition) // convert back from 2's complement

207:                     rExp < (ZERO_OFFSET - uint(MAXIMUM_EXPONENT * -1) - DIGIT_DIFF_L_M)

369:                 r := or(r, MANTISSA_SIGN_MASK) // assign the negative sign

370:                 addition := sub(0, addition) // convert back from 2's complement

409:                     rExp < (ZERO_OFFSET - uint(MAXIMUM_EXPONENT * -1) - DIGIT_DIFF_L_M)

589:                 let ptr := mload(0x40) // Get free memory pointer

590:                 mstore(ptr, 0x08c379a000000000000000000000000000000000000000000000000000000000) // Selector for method Error(string)

591:                 mstore(add(ptr, 0x04), 0x20) // String offset

592:                 mstore(add(ptr, 0x24), 26) // Revert reason length

594:                 revert(ptr, 0x64) // Revert data length is 4 bytes for selector and 3 slots of 0x20 bytes

645:                 rExp = (aExp + ZERO_OFFSET) - bExp;

704:                 let ptr := mload(0x40) // Get free memory pointer

705:                 mstore(ptr, 0x08c379a000000000000000000000000000000000000000000000000000000000) // Selector for method Error(string)

706:                 mstore(add(ptr, 0x04), 0x20) // String offset

707:                 mstore(add(ptr, 0x24), 32) // Revert reason length

709:                 revert(ptr, 0x64) // Revert data length is 4 bytes for selector and 3 slots of 0x20 bytes

720:             (aL && aExp > int(ZERO_OFFSET) - int(DIGIT_DIFF_L_M - 1)) ||

721:             (!aL && aExp > int(ZERO_OFFSET) - int(MAX_DIGITS_M / 2 - 1))

724:                 aMan *= BASE_TO_THE_DIGIT_DIFF;

725:                 aExp -= int(DIGIT_DIFF_L_M);

728:             aExp -= int(ZERO_OFFSET);

730:                 aMan *= BASE;

731:                 --aExp;

735:             int rExp = aExp - int(MAX_DIGITS_L);

739:                     rMan /= BASE;

740:                     ++rExp;

742:                 rExp = (rExp) / 2;

743:                 if (rExp <= MAXIMUM_EXPONENT - int(DIGIT_DIFF_L_M)) {

744:                     rMan /= BASE_TO_THE_DIGIT_DIFF;

745:                     rExp += int(DIGIT_DIFF_L_M);

748:                 rExp += int(ZERO_OFFSET);

```

```solidity
File: Ln.sol

4: import {packedFloat} from "./Types.sol";

5: import {Float128} from "./Float128.sol";

38:     int constant ln10_M = ln10_70 / int(10 ** (uint(70 - Float128.MAX_DIGITS_M + 1)));

39:     int constant ln2_M = ln2_70 / int(10 ** (uint(70 - Float128.MAX_DIGITS_M)));

40:     int constant ln1dot1_M = ln1dot1_70 / int(10 ** (uint(70 - Float128.MAX_DIGITS_M - 1)));

41:     int constant ln1dot01_M = ln1dot01_70 / int(10 ** (uint(70 - Float128.MAX_DIGITS_M - 2)));

42:     int constant ln1dot001_M = ln1dot001_70 / int(10 ** (uint(70 - Float128.MAX_DIGITS_M - 3)));

73:             exponent == 0 - int(inputL ? Float128.MAX_DIGITS_L_MINUS_1 : Float128.MAX_DIGITS_M_MINUS_1) &&

87:         int positiveExp = exp * -1;

93:                 mantissa /= Float128.BASE_TO_THE_DIGIT_DIFF;

94:                 exp += int(Float128.DIGIT_DIFF_L_M);

97:             uint q1 = Float128.BASE_TO_THE_MAX_DIGITS_M_X_2 / mantissa;

99:             uint q2 = (Float128.BASE_TO_THE_MAX_DIGITS_M * r1) / mantissa;

100:             uint one_over_argument_in_long_int = q1 * Float128.BASE_TO_THE_MAX_DIGITS_M + q2;

105:             m76 -= Float128.DIGIT_DIFF_76_L;

106:             one_over_arguments_76 /= Float128.BASE_TO_THE_DIFF_76_L;

108:                 --m76;

109:                 one_over_arguments_76 /= Float128.BASE;

111:             int exp_one_over_argument = 0 - int(Float128.MAX_DIGITS_M) - int(Float128.MAX_DIGITS_M_X_2) - exp;

113:                 ln(Float128.toPackedFloat(int(one_over_arguments_76), 0 - int(m76)))

115:             result = a.sub(Float128.toPackedFloat((exp_one_over_argument + int(m10)), 0).mul(ln10));

117:             int256 m10 = inputL ? int(Float128.MAX_DIGITS_L) + exp : int(Float128.MAX_DIGITS_M) + exp;

118:             exp -= m10;

120:             mantissa *= (inputL ? Float128.BASE_TO_THE_DIFF_76_L : Float128.BASE_TO_THE_MAX_DIGITS_M);

121:             exp -= int(inputL ? Float128.DIGIT_DIFF_L_M : Float128.MAX_DIGITS_M);

125:             if (mantissa > (25 * (10 ** 74))) {

126:                 if (mantissa > (50 * (10 ** 74))) {

133:                 if (mantissa > (125 * 10 ** 73)) {

141:             mantissa *= multiplier_k;

206:         int z_int = 10 ** 76 - int(mantissa);

209:             int diff = len_z_int - 38;

210:             z_int = diff < 0 ? int(uint(z_int) * 10 ** uint(diff * -1)) : int(uint(z_int) / 10 ** uint(diff));

213:         packedFloat z = Float128.toPackedFloat(z_int, (len_z_int - 76 - 38));

219:         for (uint j = 2; j < uint(terms + 1); j++) {

224:         packedFloat lnB = Float128.toPackedFloat(13902905168991420865477877458246859530, -39);

225:         packedFloat lnC = Float128.toPackedFloat(12991557316200501157605555658804528711, -40);

261:         finalResult = fifthTerm.mul(Float128.toPackedFloat(-1, 0));

271:         if (mantissa > (68300000 * 10 ** 68)) {

272:             if (mantissa > (82000000 * 10 ** 68)) {

273:                 if (mantissa > (90000000 * 10 ** 68)) {

279:                     updatedMantissa = mantissa + mantissa / 10;

282:                 if (mantissa > (75000000 * 10 ** 68)) {

284:                     updatedMantissa = mantissa + (2 * mantissa) / 10 + mantissa / 100;

287:                     updatedMantissa = mantissa + (3 * mantissa) / 10 + (3 * mantissa) / 100 + mantissa / 1000;

291:             if (mantissa > (56400000 * 10 ** 68)) {

292:                 if (mantissa > (62000000 * 10 ** 68)) {

295:                         mantissa +

296:                         (4 * mantissa) /

297:                         10 +

298:                         (6 * mantissa) /

299:                         100 +

300:                         (4 * mantissa) /

301:                         1000 +

302:                         mantissa /

307:                         mantissa +

308:                         (6 * mantissa) /

309:                         10 +

310:                         (1 * mantissa) /

311:                         100 +

312:                         (5 * mantissa) /

313:                         10000 +

314:                         (1 * mantissa) /

318:                 if (mantissa > (51200000 * 10 ** 68)) {

321:                         mantissa +

322:                         (7 * mantissa) /

323:                         10 +

324:                         (7 * mantissa) /

325:                         100 +

326:                         (1 * mantissa) /

327:                         1000 +

328:                         (5 * mantissa) /

329:                         10000 +

330:                         (6 * mantissa) /

331:                         100000 +

332:                         (1 * mantissa) /

338:                         mantissa +

339:                         (9 * mantissa) /

340:                         10 +

341:                         (4 * mantissa) /

342:                         100 +

343:                         (8 * mantissa) /

344:                         1000 +

345:                         (7 * mantissa) /

346:                         10000 +

347:                         (1 * mantissa) /

348:                         100000 +

349:                         (7 * mantissa) /

350:                         1000000 +

351:                         (1 * mantissa) /

365:         if (mantissa > (9459 * 10 ** 72)) {

366:             if (mantissa > (9725 * 10 ** 72)) {

367:                 if (mantissa > 9860 * 10 ** 72) {

373:                     updatedMantissa = mantissa + (1 * mantissa) / 100 + (4 * mantissa) / 1000;

376:                 if (mantissa > (9591 * 10 ** 72)) {

380:                         mantissa +

381:                         (2 * mantissa) /

382:                         100 +

383:                         (8 * mantissa) /

384:                         1000 +

385:                         (1 * mantissa) /

386:                         10000 +

387:                         (9 * mantissa) /

388:                         100000 +

389:                         (6 * mantissa) /

395:                         mantissa +

396:                         (4 * mantissa) /

397:                         100 +

398:                         (2 * mantissa) /

399:                         1000 +

400:                         (5 * mantissa) /

401:                         10000 +

402:                         (9 * mantissa) /

403:                         100000 +

404:                         (0 * mantissa) /

405:                         1000000 +

406:                         (7 * mantissa) /

407:                         10000000 +

408:                         (4 * mantissa) /

409:                         100000000 +

410:                         (4 * mantissa) /

415:             if (mantissa > (9199 * 10 ** 72)) {

416:                 if (mantissa > (9328 * 10 ** 72)) {

420:                         mantissa +

421:                         (5 * mantissa) /

422:                         100 +

423:                         (7 * mantissa) /

424:                         1000 +

425:                         (1 * mantissa) /

426:                         10000 +

427:                         (8 * mantissa) /

428:                         100000 +

429:                         (7 * mantissa) /

430:                         1000000 +

431:                         (0 * mantissa) /

432:                         10000000 +

433:                         (1 * mantissa) /

434:                         100000000 +

435:                         (4 * mantissa) /

436:                         1000000000 +

437:                         (4 * mantissa) /

438:                         10000000000 +

439:                         (1 * mantissa) /

440:                         100000000000 +

441:                         (6 * mantissa) /

499:                 if (mantissa > (9072 * 10 ** 72)) {

643:         if (mantissa > (991129567482 * 10 ** 64)) {

644:             if (mantissa > (993708179366 * 10 ** 64)) {

645:                 if (mantissa > (995 * 10 ** 73)) {

652:                     updatedMantissa = mantissa + (1 * mantissa) / 1000 + (3 * mantissa) / 10000;

655:                 if (mantissa > (992418035920 * 10 ** 64)) {

659:                         mantissa +

660:                         (2 * mantissa) /

661:                         1000 +

662:                         (6 * mantissa) /

663:                         10000 +

664:                         (1 * mantissa) /

665:                         1000000 +

666:                         (6 * mantissa) /

667:                         10000000 +

668:                         (9 * mantissa) /

674:                         mantissa +

675:                         (3 * mantissa) /

676:                         1000 +

677:                         (9 * mantissa) /

678:                         10000 +

679:                         (5 * mantissa) /

680:                         1000000 +

681:                         (7 * mantissa) /

682:                         100000000 +

683:                         (2 * mantissa) /

684:                         1000000000 +

685:                         (1 * mantissa) /

686:                         10000000000 +

687:                         (9 * mantissa) /

688:                         100000000000 +

689:                         (7 * mantissa) /

694:             if (mantissa > (988557646937 * 10 ** 64)) {

695:                 if (mantissa > (989842771878 * 10 ** 64)) {

810:                 if (mantissa > (987274190490 * 10 ** 64)) {

```

### <a name="GAS-2"></a>[GAS-2] `++i` costs less gas than `i++`, especially when it's used in `for`-loops (`--i`/`i--` too)
*Saves 5 gas per loop*

*Instances (1)*:
```solidity
File: Ln.sol

219:         for (uint j = 2; j < uint(terms + 1); j++) {

```

### <a name="GAS-3"></a>[GAS-3] Use shift Right/Left instead of division/multiplication if possible

*Instances (2)*:
```solidity
File: Float128.sol

721:             (!aL && aExp > int(ZERO_OFFSET) - int(MAX_DIGITS_M / 2 - 1))

742:                 rExp = (rExp) / 2;

```

### <a name="GAS-4"></a>[GAS-4] Use != 0 instead of > 0 for unsigned integer comparison

*Instances (2)*:
```solidity
File: Float128.sol

175:         if (packedFloat.unwrap(r) > 0) {

377:         if (packedFloat.unwrap(r) > 0) {

```


## Non Critical Issues


| |Issue|Instances|
|-|:-|:-:|
| [NC-1](#NC-1) | Constants should be defined rather than using magic numbers | 35 |
### <a name="NC-1"></a>[NC-1] Constants should be defined rather than using magic numbers

*Instances (35)*:
```solidity
File: Ln.sol

38:     int constant ln10_M = ln10_70 / int(10 ** (uint(70 - Float128.MAX_DIGITS_M + 1)));

39:     int constant ln2_M = ln2_70 / int(10 ** (uint(70 - Float128.MAX_DIGITS_M)));

40:     int constant ln1dot1_M = ln1dot1_70 / int(10 ** (uint(70 - Float128.MAX_DIGITS_M - 1)));

41:     int constant ln1dot01_M = ln1dot01_70 / int(10 ** (uint(70 - Float128.MAX_DIGITS_M - 2)));

42:     int constant ln1dot001_M = ln1dot001_70 / int(10 ** (uint(70 - Float128.MAX_DIGITS_M - 3)));

46:         packedFloat.wrap(57634551253070896831007164474234001986315550567012630870766974200712100735196);

48:         packedFloat.wrap(57627483864811783293688831284231030312298529498551182469036031073505904270823);

50:         packedFloat.wrap(57620416476552669756370498094228058638261215024712010322305773559835681227132);

52:         packedFloat.wrap(57613349088293556219052164904225086964202098217851863814911488587192353072694);

54:         packedFloat.wrap(57606281700034442681733831714222115290139235007041033827277788478998076322779);

125:             if (mantissa > (25 * (10 ** 74))) {

126:                 if (mantissa > (50 * (10 ** 74))) {

133:                 if (mantissa > (125 * 10 ** 73)) {

224:         packedFloat lnB = Float128.toPackedFloat(13902905168991420865477877458246859530, -39);

225:         packedFloat lnC = Float128.toPackedFloat(12991557316200501157605555658804528711, -40);

271:         if (mantissa > (68300000 * 10 ** 68)) {

272:             if (mantissa > (82000000 * 10 ** 68)) {

273:                 if (mantissa > (90000000 * 10 ** 68)) {

282:                 if (mantissa > (75000000 * 10 ** 68)) {

291:             if (mantissa > (56400000 * 10 ** 68)) {

292:                 if (mantissa > (62000000 * 10 ** 68)) {

318:                 if (mantissa > (51200000 * 10 ** 68)) {

365:         if (mantissa > (9459 * 10 ** 72)) {

366:             if (mantissa > (9725 * 10 ** 72)) {

376:                 if (mantissa > (9591 * 10 ** 72)) {

415:             if (mantissa > (9199 * 10 ** 72)) {

416:                 if (mantissa > (9328 * 10 ** 72)) {

499:                 if (mantissa > (9072 * 10 ** 72)) {

643:         if (mantissa > (991129567482 * 10 ** 64)) {

644:             if (mantissa > (993708179366 * 10 ** 64)) {

645:                 if (mantissa > (995 * 10 ** 73)) {

655:                 if (mantissa > (992418035920 * 10 ** 64)) {

694:             if (mantissa > (988557646937 * 10 ** 64)) {

695:                 if (mantissa > (989842771878 * 10 ** 64)) {

810:                 if (mantissa > (987274190490 * 10 ** 64)) {

```
