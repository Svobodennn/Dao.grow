module dao_grow::dao_grow_nft {
    use sui::object::{Self, UID, ID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use std::string::{Self, String};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::balance::{Self, Balance};

    /// Error codes
    const EInvalidRecipeData: u64 = 0;
    const ENOT_ADMIN: u64 = 1;
    const EInsufficientPayment: u64 = 2;

    /// Mint cost in MIST (0.0001 SUI = 100_000 MIST)
    const MINT_COST: u64 = 100_000;

    /// Recipe data structure containing the recipe as a string
    public struct RecipeData has store {
        recipe: String
    }

    /// The NFT representing a farming recipe
    public struct RecipeNFT has key, store {
        id: UID,
        recipe_data: RecipeData,
        creator: address,
    }

    /// Admin capability - only admin can mint NFTs
    public struct AdminCap has key {
        id: UID
    }

    /// Events
    public struct RecipeMinted has copy, drop {
        recipe_id: ID,
        creator: address,
    }

    /// Initialize module and create admin capability
    fun init(ctx: &mut TxContext) {
        transfer::transfer(
            AdminCap { id: object::new(ctx) },
            tx_context::sender(ctx)
        )
    }

    /// Create a new recipe NFT - only admin can call this
    public fun create_recipe_nft(
        _: &AdminCap,
        recipe: String,
        payment: &mut Coin<SUI>,
        ctx: &mut TxContext
    ): RecipeNFT {
        assert!(string::length(&recipe) > 0, EInvalidRecipeData);
        assert!(coin::value(payment) >= MINT_COST, EInsufficientPayment);

        // Extract payment
        let payment_coin = coin::split(payment, MINT_COST, ctx);
        transfer::public_transfer(payment_coin, tx_context::sender(ctx));

        let recipe_data = RecipeData {
            recipe
        };

        let recipe_nft = RecipeNFT {
            id: object::new(ctx),
            recipe_data,
            creator: tx_context::sender(ctx),
        };

        recipe_nft
    }

    /// Mint a new recipe NFT and transfer it to the recipient - only admin can mint
    public entry fun mint_recipe_nft(
        admin_cap: &AdminCap,
        recipe: String,
        payment: &mut Coin<SUI>,
        ctx: &mut TxContext
    ) {
        let recipe_nft = create_recipe_nft(
            admin_cap,
            recipe,
            payment,
            ctx
        );
        
        transfer::transfer(recipe_nft, tx_context::sender(ctx));
    }

    /// Get recipe data from an NFT
    public fun get_recipe_data(nft: &RecipeNFT): &RecipeData {
        &nft.recipe_data
    }

    /// Get creator address from an NFT
    public fun get_creator(nft: &RecipeNFT): address {
        nft.creator
    }
} 