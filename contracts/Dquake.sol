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
    constructor()  {
        contractOwner = msg.sender;
    }    
    
    
    // 契約処理
    function createContract(uint _town_code) payable public {
        // 入力チェック
        require(msg.value>=0.01 ether, 'The minimum premium is 100,000.');                   // 最低掛け金は100,000　wei
        require(premium_balance[msg.sender] == 0, 'The contract is once per person.');  // 契約は一人一回
        
        // 保険料を収納
        premium_balance[msg.sender] = msg.value;
        
        // 契約内容を格納
        AgreementInfo memory _agreement = AgreementInfo( msg.sender, _town_code, true);
        agreements.push(_agreement);
    }
    
    // 契約解除処理
    function withdrawContract() public {
        require(premium_balance[msg.sender] > 0, 'We can not find your contract.'); // 契約がなければエラー
        
        for( uint i=0; i < agreements.length; i++) {
            if ( agreements[i].live && agreements[i].owner == msg.sender ) {
                agreements[i].live = false;
                uint _premium = premium_balance[msg.sender] ;
                uint fee = premium_balance[msg.sender]/100; //手数料 1%
                premium_balance[msg.sender] = 0;
                payable(msg.sender).transfer(_premium - fee); //手数料を控除して返却
                
                break;
            }
        }   
    }
    
    // 地震発生時の処理
    function occurEarthQuake(uint[] memory _towns, uint[] memory _intensity) public {
        require(msg.sender == contractOwner, 'Sorry this function can be only owner.'); // オーナでなければエラー
        
        // 対象契約について震度を検索し、最大震度、総震度数を求める
        uint _intensity_all;
        uint _intensity_max;
        
        for( uint i=0; i < agreements.length; i++) {
          if (agreements[i].live) {
            for( uint j=0; j < _towns.length; j++) {
              if (agreements[i].town_code == _towns[j]) {
                _intensity_all += _intensity[j];
                if (_intensity[j]>_intensity_max) {
                  _intensity_max = _intensity[j];
                }
              }
            }
          }
        }
        require(_intensity_all > 0, "There are no contract affected by this quake. Thank you."); // 対象がなければ終了
    
        // 徴収割合を算出
        uint _ratio;
        _ratio = _intensity_max * 30 / 11;  // 震度に比例し、最大震度値11の時に30％になるように設定。
        
        // 全員から徴収
        uint _deposit_all;
        
        for( uint i=0; i < agreements.length; i++) {
          if (agreements[i].live ) {
            uint _deposit = premium_balance[agreements[i].owner] * _ratio /100; // 指定割合を徴収
            premium_balance[agreements[i].owner] -= _deposit;
            _deposit_all += _deposit;
          }
        }
        
        // １震度数当たりの割戻額を求める
        uint _rebate = _deposit_all / _intensity_all;
        
        // 対象者へ割戻す
        for( uint i=0; i < agreements.length; i++) {
          if (agreements[i].live) {
            for( uint j=0; j < _towns.length; j++) {
              if (agreements[i].town_code == _towns[j]) {
                premium_balance[agreements[i].owner] += _intensity[j] * _rebate;
              }
            }
          }
        }
    }
    
    // 全契約の解除処理
    function exodusContract() public {
        require(msg.sender == contractOwner, 'Sorry this function can be only owner.'); // オーナでなければエラー
        
        for( uint i=0; i < agreements.length; i++) {
          if ( agreements[i].live ) {
            agreements[i].live = false;
            uint _premium = premium_balance[agreements[i].owner] ;
            uint fee = premium_balance[agreements[i].owner]/100; //手数料 1%
            premium_balance[agreements[i].owner] = 0;
            payable(agreements[i].owner).transfer(_premium - fee); //手数料を控除して返却
        
          }
        }
        
        uint _final_balance;
        _final_balance = address(this).balance;
        payable(contractOwner).transfer(_final_balance);  //最終残高をオーナーに返却
    }

    // 契約件数の取得
    function getAgreementsLength() public view returns (uint) {
        return agreements.length;
    }
}