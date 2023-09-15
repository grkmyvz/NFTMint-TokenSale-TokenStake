import { ListParams } from "../helpers/types";

export default function List({
  listTitle,
  listParams,
}: {
  listTitle?: string;
  listParams: ListParams[];
}) {
  return (
    <div
      style={{
        border: "1px solid black",
        margin: "0.5rem",
      }}
    >
      {listTitle ? (
        <h3 style={{ textAlign: "center", textDecoration: "underline" }}>
          {listTitle}
        </h3>
      ) : null}
      <ul
        style={{
          display: "flex",
          listStyle: "none",
          textAlign: "center",
        }}
      >
        {listParams.map((listParam, index) => (
          <li key={index} style={{ flex: 1 }}>
            <strong>{listParam.listName}</strong>
            <br />
            {listParam.listValue}
          </li>
        ))}
      </ul>
    </div>
  );
}
