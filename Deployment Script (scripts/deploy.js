async function main() {
  const DAO = await ethers.getContractFactory("RoyalCapitalDAO");
  const dao = await DAO.deploy();
  await dao.deployed();
  console.log("RoyalCapitalDAO deployed to:", dao.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
