<?php

    require_once "./src/app/Mage.php";

    $version = Mage::getVersion();

    echo $version;