const h1 = document.body.querySelectorAll("h1")[0];

const container = document.createElement("div");
container.classList.add("contact-info");

const contactInfo = `
<LOCATION>
<EMAIL>
<PHONE>
`
  .split("\n")
  .filter((line) => line != "");

const elements = contactInfo.map((line) => {
  const el = document.createElement("div");
  el.textContent = line;
  return el;
});

container.append(...elements);

h1.after(container);
