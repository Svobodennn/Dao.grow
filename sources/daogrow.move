module daogrow::daogrow;

use std::string::String;
use sui::{sui::SUI, coin::{Coin}};
use daogrow::treasury::Treasury;

// NFT'yi temsil eden struct
public struct RecipeNFT has key, store {
    id: UID,
    name: String,
    description: String,
    recipe: String,
    price: u64,
    owner: address,
}

// NFT oluşturma fonksiyonu
#[allow(lint(self_transfer))]
public fun mint_with_fee(
    name: String,
    description: String,
    recipe: String,
    price: u64,
    treasury: &mut Treasury,
    mut account_balance: Coin<SUI>,
    ctx: &mut TxContext,
) {
    let nft_mint_fee = treasury.get_nft_mint_cost();
    assert!(account_balance.value() >= nft_mint_fee, 0);

    let fee_coin = account_balance.split(nft_mint_fee, ctx);

    transfer::public_transfer(fee_coin, treasury.get_owner());

    if (account_balance.value()==0) {
        account_balance.destroy_zero();
    } else {
        transfer::public_transfer(account_balance, tx_context::sender(ctx));
    };

    transfer::public_transfer(
        RecipeNFT {
            id: object::new(ctx),
            name,
            description,
            recipe,
            price,
            owner: tx_context::sender(ctx),
        },
        tx_context::sender(ctx)
    );
}

// public fun update_nft_price(
//     nft: &mut RecipeNFT,
//     new_price: u64,
//     ctx: &TxContext
// ) {
//     assert!(tx_context::sender(ctx) == object::owner(&nft.id), 0); // NFT sahibi kontrolü
//     nft.price = new_price;
// }

// NFT oluşturma fonksiyonu
// #[allow(lint(self_transfer))] // Kendine transfer uyarısını engelle
// public fun mint(
//     name: String,
//     description: String,
//     recipe: String,
//     ctx: &mut TxContext
// ) {
//     let nft = RecipeNFT {
//         id: object::new(ctx),
//         name,
//         description,
//         recipe
//     };

//     transfer::transfer(nft, tx_context::sender(ctx));
// }

// Ücretli NFT oluşturma fonksiyonu
// #[allow(lint(self_transfer))]
// public fun mint_with_payment(
//     payment: Coin<SUI>, // Kullanıcıdan alınacak ödeme
//     name: String,
//     description: String,
//     recipe: String,
//     ctx: &mut TxContext
// ) {
//     // Burada payment Coin'ini kullanıyoruz.
//     // İstersen buradan kesinti yapıp başka bir kasaya da atabilirsin.

//     // (Örnek: ödeme aldıktan sonra Coin'i yok etmek veya bir owner'a göndermek.)

//     let _burned = coin::burn(payment);

//     let nft = RecipeNFT {
//         id: object::new(ctx),
//         name,
//         description,
//         recipe
//     };

//     transfer::transfer(nft, tx_context::sender(ctx));
// }

// Ücretli NFT transfer fonksiyonu
// public fun transfer_with_fee(
//     nft: RecipeNFT,
//     payment: Coin<SUI>, // Transfer fee ödemesi
//     recipient: address,
//     ctx: &mut TxContext
// ) {
//     let _burned = coin::burn(payment);

//     let amount = coin::value(&payment);
//     assert!(amount >= 1_000_000, 0); // En az 1 SUI lazım (1 SUI = 1_000_000 mist)

//     transfer::transfer(nft, recipient);
// }

// Ücretli NFT oluşturma fonksiyonu (Kasaya ödeme)
// #[allow(lint(self_transfer))]
// public fun mint_with_payment(
//     treasury: &mut Treasury,  // Kasa referansı
//     payment: Coin<SUI>,       // Kullanıcıdan alınan ödeme
//     name: String,
//     description: String,
//     recipe: String,
//     ctx: &mut TxContext
// ) {
//     // Ödeme kasanın sahibine gidiyor
//     coin::transfer(payment, treasury.owner, ctx);

//     let nft = RecipeNFT {
//         id: object::new(ctx),
//         name,
//         description,
//         recipe
//     };

//     transfer::transfer(nft, tx_context::sender(ctx));
// }

// Ücretli NFT transfer fonksiyonu (Kasaya ödeme)
// public fun transfer_with_fee(
//     treasury: &mut Treasury,
//     nft: RecipeNFT,
//     payment: Coin<SUI>,
//     recipient: address,
//     ctx: &mut TxContext
// ) {
//     coin::transfer(payment, treasury.owner, ctx);

//     transfer::transfer(nft, recipient);
// }
