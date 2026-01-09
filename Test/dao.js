const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("RoyalCapitalDAO", function () {
  let DAO, dao, founder, member1, member2;

  beforeEach(async function () {
    [founder, member1, member2] = await ethers.getSigners();
    DAO = await ethers.getContractFactory("RoyalCapitalDAO");
    dao = await DAO.deploy();
    await dao.deployed();

    // Add members
    await dao.connect(founder).addMember(member1.address);
    await dao.connect(founder).addMember(member2.address);
  });

  it("should accept treasury deposits", async function () {
    await founder.sendTransaction({ to: dao.address, value: ethers.parseEther("1") });
    expect(await dao.getTreasuryBalance()).to.equal(ethers.parseEther("1"));
  });

  it("should create, vote, assure, and execute a proposal", async function () {
    // Deposit funds
    await founder.sendTransaction({ to: dao.address, value: ethers.parseEther("1") });

    // Create proposal
    await dao.connect(member1).createProposal("Fund member2", member2.address, ethers.parseEther("0.5"));

    // Vote
    await dao.connect(member1).vote(0, true);
    await dao.connect(member2).vote(0, true);

    // Assure
    await dao.connect(founder).assureProposal(0);

    // Execute
    await dao.connect(founder).executeProposal(0);

    expect(await dao.getTreasuryBalance()).to.equal(ethers.parseEther("0.5"));
  });
});npx hardhat test
