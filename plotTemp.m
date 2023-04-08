clc
clear all
close all
tenOne = [2377        1770        2248        1952        1441        1877        2137        1316        1307        2620        1939        1219        1676        2070        1128        1963        1869        1445        2018        1573        1642        1266        1841        1502        1606        2158        1775        1743        1725        1908        1906        1686        2063        1294        2157        1501        1380        1495        1648       1906        1351        2049        1871        1633        1409        1872        1813        1909        1376        1900        1902        2088        1352        1984        1834        1659        1567        2331        1545        1749        1951        1401        1882        1440        1555        1783        1573        1498        1784        2384        2177        1713        2132        1329        1535        1775        1689        2279        1551        2252        1898        1386        1439        1933        2139        1683        1999        1379        1609        1427        1313    2031        2085        2012        2293        1656        1120        1271        1728        1954];
tenTwo = [2377        1770        2248        1952        1441        1877        2137        1316        1307        2620        1939    1219        1676        2070        1128        1963        1869        1445        2018        1573        1642        1266    1841        1502        1606        2158        1775        1743        1725        1908        1906        1686        2063    1294        2157        1501        1380        1495        1648        1906        1351        2049        1871        1633    1409        1872        1813        1909        1376        1900        1902        2088        1352        1984        1834    1659        1567        2331        1545        1749        1951        1401        1882        1440        1555        1783    1573        1498        1784        2384        2177        1713        2132        1329        1535        1775        1689    2279        1551        2252        1898        1386        1439        1933        2139        1683        1999        1379    1609        1427        1313        2031        2085        2012        2293        1656        1120        1271        1728        1954];
tweOne = [4980        4435        3776        3231        3988        5263        3458        3684        4073        3280        4151        3461    4502        4377        3938        4361        3726        3697        5364        3098        3932        4182        3848        4069   3751        3249        5501        4064        3782        3976        3463        3736        3920        4435        3890        3680  2827        3762        4430        3849        3515        3841        4347        4154        2847        3279        3864        3990     3852        3531        4884        3613        4179        3242        3763        4334        4136        4298        3421        3547    3563        3745        3761        4568        4345        4767        3911        4118        3860        3186        4714        3666   3430        3547        3685        4513        3585        4711        5015        3980        4091        3646        3127        4107  3771        4417        2898        3923        3589        3644        3917        3728        3589        4429        4697        4661     3255        4304        3615        4362];
tweTwo = [4087        3938        3568        3110        3215        3070        2997        3447        4142        3930        3807        3154        3281        3220        4376        3736        3323        3106        3010        3071        3607        3185        3327        3333        3219        3478        3387        3731        3518        4692        3725        3698        4649        3479        3638        3184        3076        3258        3352        3091        2875        3043        3711        3781        4396        3198        3076        3242        3215        3515        2889        3732        3852        3143        3541        3058        3335        3508        3969        3429        3523        3029        3972        3300        4028        4325        2958        3390        3153        3846        3459        3095        3907        3052        2612        3119        2696        3790        3346        3487        4195        4037        3761        3449        3605        4063        3588        4633        4502        3186        4101        3757        2537        3608        3392        2986        3983        3352        3132        3311];
X = zeros(1,100);
for i = 1 : 100
    X(i) = i;
end
tenOne = sort(tenOne);
tenTwo = sort(tenTwo);
tweOne = sort(tweOne);
tweTwo = sort(tweTwo);
figure;

plot(X,tweOne);
hold on;

plot(X,tweTwo);

legend('one','two')