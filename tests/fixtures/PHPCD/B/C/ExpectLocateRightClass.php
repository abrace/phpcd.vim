<?php
namespace PHPCD\B\C;

use PHPCD\SameName\A\Same;
use PHPCD\SameName\B\Same as SameB;

class ExpectJumpToRightClass
{
    public function xxx()
    {
        $a = new Same();
        $b = new SameB();

        $a->pa;
        $b->pa;

        Same::CA;
        SameB::CA;

        Same::getInstance()->na();
        Same::getInstance()->nb();
    }
}
