// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Dquake {

    // 変数の定義
    struct AgreementInfo {  // 契約内容の構造体
        address owner;      // 契約者
        uint    town_code;  // 市区町村コード
        bool    live;       // 生存フラグ
    }

    address     public  contractOwner;  // コントラクト作成者
    AgreementInfo[] public agreements;  // 契約内容の配列　0スタート
    mapping (address => uint256) public premium_balance;  // 各契約者別の保険料
    
    // コンストラクター
    
    // 契約処理
    function createContract(uint _town_code) payable public {
    }
    
    // 契約解除処理
    function withdrawContract() public {
    }
    
    // 地震発生時の処理
    function occurEarthQuake(uint[] memory _towns, uint[] memory _intensity) public {
    }
    
    // 全契約の解除処理
    function exodusContract() public {
    }
}
