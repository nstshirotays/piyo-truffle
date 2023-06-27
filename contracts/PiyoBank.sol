// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PiyoCoin.sol";

contract PiyoBank {

    // 預入アカウント別の開始日時をマッピングします
    mapping(address => uint) public depoStart;
    // 預入アカウント別の預入額をマッピングします
    mapping(address => uint) public ethBalance;
    // 預入アカウント別の口座ロックフラグをマッピングします    
    mapping(address => bool) public isDepo;

    // 預入アカウント別の担保Etherをマッピングします
    mapping(address => uint) public collateralEth;
    // 預入アカウント別の貸出ロックフラグをマッピングします    
    mapping(address => bool) public isLoan;

    // ピヨコインを内部トークンとして宣言します    
    PiyoCoin private pcoin;
    
    constructor(PiyoCoin _pcoin) {
        // マイグレート時にPiyoCoinコントラクトのアドレスが渡されます
        pcoin = _pcoin;
    }

    // 預入関数
    function deposit() payable public {
        // 口座がロックされているかチェックします
        require(isDepo[msg.sender] == false, 'You are already deposit.');
        // 最低預入額を満たしているかチェックします
        require(msg.value>=1e16, 'Error, deposit must be >= 0.01 ETH');
        
        // 預入額を保存します
        ethBalance[msg.sender] = msg.value;
        // 預入開始日時を保存します
        depoStart[msg.sender] = block.timestamp;
        // 口座ロックフラグを設定します        
        isDepo[msg.sender] = true; //activate deposit status

    }

    // 払戻関数
    function withdraw() public {
        // 口座がロックされていることを確認します
        require(isDepo[msg.sender]==true, 'You are not deposit');
        
        // 預入期間を算出します
        uint depoTerm = block.timestamp - depoStart[msg.sender];

        // 年利３％(一年を365日とする)で利息をPiyoCoin(交換レート1eth=30piyo)で算出します
        uint interest = ethBalance[msg.sender] * 103 * depoTerm * 30 / 31536000  / 100;

        // 預入額を保存します        
        uint amount = ethBalance[msg.sender];
        // 預入額をクリアします
        ethBalance[msg.sender] = 0;
        // 預入額を払い戻します（手数料は取りません）
        payable(msg.sender).transfer(amount);
        
        // 利息を支払います
        pcoin.mint( payable(msg.sender), interest);
        // 口座ロックフラグを解除します        
        isDepo[msg.sender] = false;
    }


    // ローン関数
    function loan() payable public {
        require(msg.value>=1e16, 'please more than 0.01 ETH');
        require(isLoan[msg.sender] == false, 'You are already to loan');
        
        collateralEth[msg.sender] = collateralEth[msg.sender] + msg.value;
        
        uint tokensToMint = collateralEth[msg.sender] * 30;
        
        pcoin.mint(payable(msg.sender), tokensToMint);
        
        isLoan[msg.sender] = true;
        
    }
    
    // 返済関数
    function pay() public {
        require(isLoan[msg.sender] == true, 'You are not in loan');
        require(pcoin.transferFrom(msg.sender, address(this), collateralEth[msg.sender]*30), "Not enough piyo"); //must approve piyoLoan 1'st
        
        uint fee = collateralEth[msg.sender]/100; //手数料 1%
        
        payable(msg.sender).transfer(collateralEth[msg.sender]-fee);
        
        collateralEth[msg.sender] = 0;
        isLoan[msg.sender] = false;
        
    }

    // Piyoコイン交換
    function change2piyo() payable public {
        require(msg.value==1e17, 'We accept only 0.1 ETH');
        pcoin.mint(payable(msg.sender), 30*1e17);
    }

}